import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../translations.js" as Tr

TextField {
    id: root

    property color colBackground: "#1c1b1c"
    property color colText: "#cbc5ca"
    property color colPlaceholder: "#948f94"
    property color colAccent: "#bac9d1"
    property string fontFamily: "Google Sans Flex Medium"
    property int fontSize: 15
    property bool failed: false

    // Material shape icon names for password characters
    property var charIcons: [
        "star_rate", "diamond", "pentagon", "hexagon",
        "change_history", "circle", "square"
    ]

    function loginFailed() {
        failed = true
        text = ""
        shakeAnim.restart()
        failedTimer.restart()
    }

    Timer {
        id: failedTimer
        interval: 2000
        onTriggered: root.failed = false
    }

    Layout.fillHeight: true
    implicitWidth: 200
    padding: 10

    placeholderText: failed ? Tr.tr("incorrect_password") : Tr.tr("enter_password")
    placeholderTextColor: root.colPlaceholder
    // Make actual password text transparent (overlay shows the shapes)
    color: text.length > 0 ? "transparent" : root.colText
    echoMode: TextInput.Password
    inputMethodHints: Qt.ImhSensitiveData

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        hintingPreference: Font.PreferFullHinting
    }
    renderType: Text.NativeRendering

    background: Rectangle {
        color: root.colBackground
        radius: 9999
    }

    // Clip text to pill shape
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width - 8
            height: root.height
            radius: height / 2
        }
    }

    // Material shapes overlay for password characters
    Row {
        anchors.left: parent.left
        anchors.leftMargin: root.padding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        visible: root.text.length > 0

        Repeater {
            model: root.text.length

            Item {
                required property int index
                implicitWidth: 0
                implicitHeight: charIcon.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: charIcon
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 18
                    font.variableAxes: ({ "FILL": 1 })
                    text: root.charIcons[index % root.charIcons.length]
                    color: root.colAccent
                    renderType: Text.NativeRendering
                    scale: 0.5
                    opacity: 0
                }

                Component.onCompleted: appearAnim.start()

                ParallelAnimation {
                    id: appearAnim
                    NumberAnimation {
                        target: charIcon
                        property: "opacity"
                        to: 1
                        duration: 50
                    }
                    NumberAnimation {
                        target: charIcon
                        property: "scale"
                        to: 1
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
                    }
                    NumberAnimation {
                        target: charIcon.parent
                        property: "implicitWidth"
                        to: 21
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
                    }
                    ColorAnimation {
                        target: charIcon
                        property: "color"
                        from: root.colAccent
                        to: root.colText
                        duration: 1000
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }

    // Shake animation on wrong password
    transform: Translate { id: shakeTranslate; x: 0 }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shakeTranslate; property: "x"; to: -30; duration: 50 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 30; duration: 50 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: -15; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 15; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; to: 0; duration: 30 }
    }
}
