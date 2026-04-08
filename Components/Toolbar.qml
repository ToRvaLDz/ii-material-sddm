import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property color colBackground: "#201f20"
    property color colShadow: "#000000"
    property real padding: 8
    property alias spacing: toolbarLayout.spacing
    default property alias data: toolbarLayout.data

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.colBackground
        implicitHeight: 56
        implicitWidth: toolbarLayout.implicitWidth + root.padding * 2
        radius: height / 2

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 9
            samples: 19
            color: Qt.rgba(0, 0, 0, 0.3)
            cached: true
        }

        RowLayout {
            id: toolbarLayout
            spacing: 4
            anchors {
                fill: parent
                margins: root.padding
            }
        }
    }
}
