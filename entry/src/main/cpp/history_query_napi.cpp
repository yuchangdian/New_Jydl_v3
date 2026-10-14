#include "history_query_napi.h"

#include "third_party/sqlite/sqlite3.h"

#include <cstdint>
#include <cstring>
#include <memory>
#include <string>
#include <unordered_map>

namespace {
struct Query {
    sqlite3 *db = nullptr;
    sqlite3_stmt *statement = nullptr;
    std::int64_t rowIndex = 0;
    int sampleStep = 1;
    bool done = false;
    bool distortion = false;

    ~Query() {
        if (statement) sqlite3_finalize(statement);
        if (db) sqlite3_close(db);
    }
};

std::unordered_map<int, std::unique_ptr<Query>> queries;
int nextId = 1;

void Throw(napi_env env, const std::string &message) {
    napi_throw_error(env, nullptr, message.c_str());
}

bool StringArg(napi_env env, napi_value arg, std::string &value) {
    std::size_t length = 0;
    if (napi_get_value_string_utf8(env, arg, nullptr, 0, &length) != napi_ok) return false;
    value.resize(length + 1);
    if (napi_get_value_string_utf8(env, arg, &value[0], length + 1, &length) != napi_ok) return false;
    value.resize(length);
    return true;
}

bool NumberArg(napi_env env, napi_value arg, std::int64_t &value) {
    double number = 0;
    if (napi_get_value_double(env, arg, &number) != napi_ok) return false;
    value = static_cast<std::int64_t>(number);
    return true;
}

void PutNumber(napi_env env, napi_value object, const char *name, std::int64_t value) {
    napi_value number = nullptr;
    napi_create_double(env, static_cast<double>(value), &number);
    napi_set_named_property(env, object, name, number);
}

void PutBlob(napi_env env, napi_value object, const char *name, sqlite3_stmt *stmt, int column) {
    const int length = sqlite3_column_bytes(stmt, column);
    const void *source = sqlite3_column_blob(stmt, column);
    void *destination = nullptr;
    napi_value buffer = nullptr;
    napi_create_arraybuffer(env, length, &destination, &buffer);
    if (length > 0 && source) std::memcpy(destination, source, length);
    napi_set_named_property(env, object, name, buffer);
}
}

napi_value OpenHistoryQuery(napi_env env, napi_callback_info info) {
    std::size_t argc = 6;
    napi_value args[6] = {};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc != 6) {
        Throw(env, "历史查询参数不完整");
        return nullptr;
    }
    std::string path, table;
    std::int64_t start = 0, end = 0, address = 0, step = 1;
    if (!StringArg(env, args[0], path) || !StringArg(env, args[1], table)
        || !NumberArg(env, args[2], start) || !NumberArg(env, args[3], end)
        || !NumberArg(env, args[4], address) || !NumberArg(env, args[5], step)) {
        Throw(env, "历史查询参数无效");
        return nullptr;
    }
    const bool distortion = table == "Package_YC_Distortion_Struct";
    if (table != "Package_YC_BaseValue_Struct" && table != "Package_YC_PowerQuality_Struct"
        && !distortion) {
        Throw(env, "不支持的历史数据表");
        return nullptr;
    }
    auto query = std::make_unique<Query>();
    if (sqlite3_open_v2(path.c_str(), &query->db, SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, nullptr)
        != SQLITE_OK) {
        Throw(env, "历史数据库无法读取：" + path);
        return nullptr;
    }
    sqlite3_busy_timeout(query->db, 3000);
    const std::string sql = distortion
        ? "SELECT CreatedAtMs,TimeMs,ObjectAddress,Rms,Angle FROM Package_YC_Distortion_Struct "
          "WHERE CreatedAtMs>=? AND CreatedAtMs<? AND ObjectAddress=? ORDER BY CreatedAtMs,Id"
        : "SELECT CreatedAtMs,TimeMs,Payload FROM " + table
          + " WHERE CreatedAtMs>=? AND CreatedAtMs<? ORDER BY CreatedAtMs,Id";
    if (sqlite3_prepare_v2(query->db, sql.c_str(), -1, &query->statement, nullptr) != SQLITE_OK) {
        Throw(env, "历史数据查询失败：" + std::string(sqlite3_errmsg(query->db)));
        return nullptr;
    }
    sqlite3_bind_int64(query->statement, 1, start);
    sqlite3_bind_int64(query->statement, 2, end);
    if (distortion) sqlite3_bind_int(query->statement, 3, static_cast<int>(address));
    query->sampleStep = step > 1 ? static_cast<int>(step) : 1;
    query->distortion = distortion;
    const int id = nextId++;
    queries[id] = std::move(query);
    napi_value result = nullptr;
    napi_create_int32(env, id, &result);
    return result;
}

napi_value NextHistoryBatch(napi_env env, napi_callback_info info) {
    std::size_t argc = 1;
    napi_value arg = nullptr;
    napi_get_cb_info(env, info, &argc, &arg, nullptr, nullptr);
    int id = 0;
    if (argc != 1 || napi_get_value_int32(env, arg, &id) != napi_ok || queries.find(id) == queries.end()) {
        Throw(env, "历史查询句柄无效");
        return nullptr;
    }
    Query &query = *queries[id];
    napi_value response = nullptr, rows = nullptr;
    napi_create_object(env, &response);
    napi_create_array(env, &rows);
    int selected = 0, scanned = 0;
    while (!query.done && selected < 250 && scanned < 5000) {
        const int status = sqlite3_step(query.statement);
        if (status == SQLITE_DONE) {
            query.done = true;
            break;
        }
        if (status != SQLITE_ROW) {
            Throw(env, "历史数据读取失败：" + std::string(sqlite3_errmsg(query.db)));
            return nullptr;
        }
        ++scanned;
        if (query.rowIndex++ % query.sampleStep != 0) continue;
        napi_value row = nullptr;
        napi_create_object(env, &row);
        PutNumber(env, row, "timestampMs", sqlite3_column_int64(query.statement, 0));
        PutNumber(env, row, "timeMs", sqlite3_column_int64(query.statement, 1));
        if (query.distortion) {
            PutNumber(env, row, "address", sqlite3_column_int(query.statement, 2));
            PutBlob(env, row, "rms", query.statement, 3);
            PutBlob(env, row, "angle", query.statement, 4);
        } else {
            PutBlob(env, row, "payload", query.statement, 2);
        }
        napi_set_element(env, rows, selected++, row);
    }
    napi_set_named_property(env, response, "rows", rows);
    napi_value done = nullptr;
    napi_get_boolean(env, query.done, &done);
    napi_set_named_property(env, response, "done", done);
    return response;
}

napi_value CloseHistoryQuery(napi_env env, napi_callback_info info) {
    std::size_t argc = 1;
    napi_value arg = nullptr;
    napi_get_cb_info(env, info, &argc, &arg, nullptr, nullptr);
    int id = 0;
    if (argc == 1 && napi_get_value_int32(env, arg, &id) == napi_ok) queries.erase(id);
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}
