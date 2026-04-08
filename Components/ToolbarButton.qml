import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal clicked()

    property bool toggled: false
    property string iconText: ""
    property color iconColor: "#cbc5ca"
    property real iconSize: 22

    property color colBackground: "transparent"
    property color colBackgroundHover: Qt.rgba(1, 1, 1, 0.08)
    property color colBackgroundToggled: "#cbc4cb"
    property color colBackgroundToggledHover: Qt.lighter("#cbc4cb", 1.1)
    property color colShadow: "#000000"

    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed

    Layout.fillHeight: true
    implicitWidth: Math.max(height, iconLabel.implicitWidth + 16)
    implicitHeight: 40

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: height / 2
        color: root.toggled
            ? (root.hovered ? root.colBackgroundToggledHover : root.colBackgroundToggled)
            : (root.hovered ? root.colBackgroundHover : root.colBackground)

        Behavior on color {
            ColorAnimation { duration: 80 }
        }
    }

    Text {
        id: iconLabel
        anchors.centerIn: parent
        text: root.iconText
        font.family: "Material Symbols Rounded"
        font.pixelSize: root.iconSize
        color: root.iconColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    scale: pressed ? 0.92 : 1.0
    Behavior on scale {
        NumberAnimation { duration: 80 }
    }
}
