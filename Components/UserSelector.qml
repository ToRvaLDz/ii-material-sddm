import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal userChanged(int index)

    property int currentIndex: 0
    property int userCount: 1
    property string userName: "User"
    property color colText: "#cbc5ca"
    property string fontFamily: "Google Sans Flex Medium"
    property int fontSize: 15

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Material Symbols Rounded"
            font.pixelSize: 22
            text: "account_circle"
            color: root.colText
            renderType: Text.NativeRendering
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.userName
            color: root.colText
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.userCount > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.userCount > 1) {
                var nextIdx = (root.currentIndex + 1) % root.userCount
                root.userChanged(nextIdx)
            }
        }
    }
}
