import QtQuick
import QtQuick.VirtualKeyboard

InputPanel {
    id: virtualKeyboard
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
}
