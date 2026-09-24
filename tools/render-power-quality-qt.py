"""渲染用户提供的原始 Qt UI，用于 ArkUI 布局对照，不改写参考文件。"""
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
source = Path(r'C:\Users\Lenovo\Documents\临时代码文档\qt\告警定值\CommonSetting_PowerQuality_Set.ui')
output = Path(__file__).resolve().parents[1] / 'md' / 'alarm-setting-ui'
output.mkdir(parents=True, exist_ok=True)
widget = uic.loadUi(str(source))
# 与 Qt 构造函数中的实际运行时修正一致。
for combo in widget.findChildren(QtWidgets.QComboBox):
    if combo.objectName().startswith('C_Box_PQual_En_'):
        combo.setFixedWidth(65)
        view = QtWidgets.QListView(combo)
        view.setMinimumHeight(76)
        view.setMaximumHeight(76)
        combo.setView(view)
widget.resize(854, 480)
widget.show()
app.processEvents()
widget.grab().save(str(output / 'qt-top.png'))
geometry = {}
for child in widget.findChildren(QtWidgets.QWidget):
    if child.objectName():
        point = child.mapTo(widget, QtCore.QPoint(0, 0))
        geometry[child.objectName()] = {
            'x': point.x(), 'y': point.y(), 'width': child.width(), 'height': child.height(),
            'text': child.text() if isinstance(child, (QtWidgets.QLabel, QtWidgets.QLineEdit, QtWidgets.QPushButton)) else '',
            'visible': child.isVisible(),
        }
(output / 'qt-geometry.json').write_text(json.dumps(geometry, ensure_ascii=False, indent=2), encoding='utf-8')
widget.scrollArea.verticalScrollBar().setValue(widget.scrollArea.verticalScrollBar().maximum())
app.processEvents()
widget.grab().save(str(output / 'qt-bottom.png'))
print(json.dumps({key: geometry[key] for key in [
    'headerFrame', 'scrollArea', 'row_VoltageRef', 'C_Box_PQual_VoltageRef',
    'row_RecordLength', 'label_RecordLengthNormal', 'L_Edit_PQual_RecoedSize_Normal',
    'recordLengthNormalUnit', 'label_RecordLengthViolation', 'L_Edit_PQual_RecoedSize_Violation',
    'row_VoltageUnbalance', 'label_Enable_VoltageUnbalance', 'C_Box_PQual_En_VoltageUnbalance',
    'label_Value_VoltageUnbalance', 'L_Edit_PQual_Val_VoltageUnbalance', 'unit_VoltageUnbalance',
    'footerBar', 'label_change', 'pushButton', 'pushButton_2', 'dateLabel', 'timeLabel'
]}, ensure_ascii=False, indent=2))
