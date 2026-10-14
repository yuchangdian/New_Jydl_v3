"""离屏渲染原始 Qt 历史导出页面，记录运行后的实际控件坐标。"""
import json
import os
from pathlib import Path

os.environ['QT_QPA_PLATFORM'] = 'offscreen'
os.environ['QT_AUTO_SCREEN_SCALE_FACTOR'] = '0'
from PyQt5 import QtCore, QtGui, QtWidgets, uic

QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_DisableHighDpiScaling)
app = QtWidgets.QApplication([])
QtGui.QFontDatabase.addApplicationFont('C:/Windows/Fonts/msyh.ttc')
app.setFont(QtGui.QFont('Microsoft YaHei', 10))
source = Path(r'C:\Users\Lenovo\Documents\临时代码文档\qt\powerQualityHistory\PowerQualityHistoryPage.ui')
output = Path(r'E:\baidu\arkTS_code\New_Jydl_v3\md\history-export-ui')
output.mkdir(parents=True, exist_ok=True)
widget = uic.loadUi(str(source))
now = QtCore.QDateTime.currentDateTime()
widget.startDateEdit.setDate(now.date())
widget.startTimeEdit.setTime(QtCore.QTime(0, 0))
widget.endDateEdit.setDate(now.date())
widget.endTimeEdit.setTime(QtCore.QTime(now.time().hour(), now.time().minute()))
widget.dateTimeLabel.setText(now.toString('yyyy/MM/dd HH:mm:ss'))
widget.exportButton.setFocus(QtCore.Qt.OtherFocusReason)
widget.show()
app.processEvents()
widget.grab().save(str(output / 'qt-page.png'))
geometry = {}
for child in widget.findChildren(QtWidgets.QWidget):
    if not child.objectName():
        continue
    point = child.mapTo(widget, QtCore.QPoint())
    item = {'x': point.x(), 'y': point.y(), 'width': child.width(), 'height': child.height()}
    if hasattr(child, 'text'):
        item['text'] = child.text()
    item['fontFamily'] = child.font().family()
    item['fontPixelSize'] = child.font().pixelSize()
    item['fontPointSize'] = child.font().pointSizeF()
    if isinstance(child, QtWidgets.QCheckBox):
        option = QtWidgets.QStyleOptionButton()
        child.initStyleOption(option)
        for name, element in [('indicator', QtWidgets.QStyle.SE_CheckBoxIndicator),
                              ('label', QtWidgets.QStyle.SE_CheckBoxContents)]:
            rect = child.style().subElementRect(element, option, child)
            item[name] = {'x': rect.x(), 'y': rect.y(), 'width': rect.width(), 'height': rect.height()}
    geometry[child.objectName()] = item
(output / 'qt-geometry.json').write_text(json.dumps(geometry, ensure_ascii=False, indent=2), encoding='utf-8')

# 捕获 Qt 原生复选框指示器，避免 ArkUI 默认圆角、填充色改变原外观。
checkbox = widget.baseValueCheckBox
for checked, name in [(True, 'qt-checkbox-checked.png'), (False, 'qt-checkbox-unchecked.png')]:
    checkbox.setChecked(checked)
    app.processEvents()
    option = QtWidgets.QStyleOptionButton()
    checkbox.initStyleOption(option)
    rect = checkbox.style().subElementRect(QtWidgets.QStyle.SE_CheckBoxIndicator, option, checkbox)
    checkbox.grab(rect).save(str(output / name))
checkbox.setChecked(True)

# 对照 .cpp 中 selectDate 创建的日历及月份菜单。
dialog = QtWidgets.QDialog(widget, QtCore.Qt.Dialog | QtCore.Qt.FramelessWindowHint)
dialog.setLocale(QtCore.QLocale(QtCore.QLocale.Chinese, QtCore.QLocale.China))
layout = QtWidgets.QVBoxLayout(dialog)
calendar = QtWidgets.QCalendarWidget(dialog)
calendar.setLocale(dialog.locale())
calendar.setGridVisible(True)
calendar.setSelectedDate(now.date())
month_button = calendar.findChild(QtWidgets.QToolButton, 'qt_calendar_monthbutton')
month_menu = QtWidgets.QMenu(month_button)
month_panel = QtWidgets.QWidget(month_menu)
month_layout = QtWidgets.QGridLayout(month_panel)
month_layout.setContentsMargins(6, 6, 6, 6)
month_layout.setSpacing(4)
for month in range(1, 13):
    button = QtWidgets.QPushButton(f'{month}月', month_panel)
    button.setCheckable(True)
    button.setChecked(month == now.date().month())
    button.setMinimumSize(72, 32)
    month_layout.addWidget(button, (month - 1) // 2, (month - 1) % 2)
action = QtWidgets.QWidgetAction(month_menu)
action.setDefaultWidget(month_panel)
month_menu.addAction(action)
month_button.setMenu(month_menu)
layout.addWidget(calendar)
buttons = QtWidgets.QDialogButtonBox(QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel,
                                     QtCore.Qt.Horizontal, dialog)
buttons.button(QtWidgets.QDialogButtonBox.Ok).setText('确定')
buttons.button(QtWidgets.QDialogButtonBox.Cancel).setText('取消')
layout.addWidget(buttons)
dialog.ensurePolished()
scale = 1.2
popup_size = dialog.sizeHint() * scale
font = calendar.font()
calendar.setStyleSheet(f'QCalendarWidget, QCalendarWidget QWidget {{ font-size:{font.pointSizeF() * scale}pt; }}')
for button in calendar.findChildren(QtWidgets.QToolButton):
    button.setIconSize(button.iconSize() * scale)
buttons.setCenterButtons(True)
buttons.setStyleSheet('QPushButton { font-size:22px; min-width:96px; min-height:46px; border-radius:14px; }')
margins = layout.contentsMargins()
layout.setContentsMargins(*(round(value * scale) for value in
                          [margins.left(), margins.top(), margins.right(), margins.bottom()]))
layout.setSpacing(round(layout.spacing() * scale))
calendar.setSizePolicy(QtWidgets.QSizePolicy.Ignored, QtWidgets.QSizePolicy.Ignored)
calendar.findChild(QtWidgets.QTableView).verticalHeader().setMinimumSectionSize(1)
dialog.resize(popup_size.boundedTo(QtCore.QSize(854, 325)))
dialog.move(widget.mapToGlobal(QtCore.QPoint(max(0, 188 + 147 // 2 - dialog.width() // 2), 155)))
dialog.show()
app.processEvents()
calendar_geometry = {'dialog': {'x': dialog.x() - widget.x(), 'y': dialog.y() - widget.y(),
                                'width': dialog.width(), 'height': dialog.height()},
                     'requested': {'width': popup_size.width(), 'height': popup_size.height()}}
for name in ['prevmonth', 'nextmonth']:
    arrow = calendar.findChild(QtWidgets.QToolButton, f'qt_calendar_{name}')
    arrow.icon().pixmap(arrow.iconSize()).save(str(output / f'qt-calendar-{name}.png'))
for child in dialog.findChildren(QtWidgets.QWidget):
    point = child.mapTo(dialog, QtCore.QPoint())
    name = child.objectName() or child.metaObject().className()
    calendar_geometry[name] = {'x': point.x(), 'y': point.y(), 'width': child.width(), 'height': child.height()}
image = widget.grab()
painter = QtGui.QPainter(image)
painter.drawPixmap(QtCore.QPoint(calendar_geometry['dialog']['x'], 155), dialog.grab())
painter.end()
image.save(str(output / 'qt-calendar.png'))
dialog.grab().save(str(output / 'qt-calendar-dialog.png'))
(output / 'qt-calendar-geometry.json').write_text(json.dumps(calendar_geometry, ensure_ascii=False, indent=2), encoding='utf-8')
month_menu.popup(month_button.mapToGlobal(QtCore.QPoint(0, month_button.height())))
app.processEvents()
month_menu.grab().save(str(output / 'qt-calendar-months.png'))
month_menu.hide()
dialog.hide()
message = QtWidgets.QMessageBox(widget)
message.setWindowTitle('导出提示')
message.setText('结束时间必须晚于开始时间。')
message.setIcon(QtWidgets.QMessageBox.Warning)
message.setStandardButtons(QtWidgets.QMessageBox.Ok)
message.ensurePolished()
message.resize(message.sizeHint())
message.layout().activate()
app.processEvents()
message.grab().save(str(output / 'qt-feedback.png'))
feedback_geometry = {'dialog': {'width': message.width(), 'height': message.height()}}
for child in message.findChildren(QtWidgets.QWidget):
    point = child.mapTo(message, QtCore.QPoint())
    feedback_geometry[child.objectName() or child.metaObject().className()] = {
        'x': point.x(), 'y': point.y(), 'width': child.width(), 'height': child.height(),
        'text': child.text() if hasattr(child, 'text') else ''}
    if isinstance(child, QtWidgets.QLabel) and child.pixmap():
        child.pixmap().save(str(output / 'qt-warning.png'))
(output / 'qt-feedback-geometry.json').write_text(json.dumps(feedback_geometry, ensure_ascii=False, indent=2), encoding='utf-8')
message.setIcon(QtWidgets.QMessageBox.Information)
message.findChild(QtWidgets.QLabel, 'qt_msgboxex_icon_label').pixmap().save(str(output / 'qt-information.png'))
print(json.dumps({'page': geometry, 'calendar': calendar_geometry}, ensure_ascii=False, indent=2))
