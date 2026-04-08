import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../translations.js" as Tr

Item {
    id: root

    property color colFace: "#3b494f"
    property color colOnFace: "#d6e5ed"
    property color colHourHand: "#bac9d1"
    property color colMinuteHand: "#b4cad5"
    property color colShadow: "#000000"
    property color colSecondaryContainer: "#40484c"
    property color colOnSecondaryContainer: "#dce4e9"
    property color colTertiaryContainer: "#354a53"
    property color colOnTertiaryContainer: "#cfe6f2"
    property string fontFamily: "Google Sans Flex"
    property int timeFontWeight: Font.Bold
    property real clockSize: 230
    property bool showLocked: true
    property int sides: 12

    width: clockSize
    height: clockColumn.implicitHeight

    Column {
        id: clockColumn
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Item {
            id: clockFace
            width: root.clockSize
            height: root.clockSize
            anchors.horizontalCenter: parent.horizontalCenter

            // Scalloped face (SineCookie style)
            Canvas {
                id: faceCanvas
                anchors.fill: parent
                anchors.margins: -15
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    var cx = width / 2
                    var cy = height / 2
                    var amplitude = root.clockSize / 35
                    var radius = root.clockSize / 2 - amplitude
                    var steps = 360

                    ctx.beginPath()
                    for (var i = 0; i <= steps; i++) {
                        var angle = (i / steps) * 2 * Math.PI
                        var rotatedAngle = angle * root.sides + Math.PI / 2
                        var wave = Math.sin(rotatedAngle) * amplitude
                        var x = Math.cos(angle) * (radius + wave) + cx
                        var y = Math.sin(angle) * (radius + wave) + cy
                        if (i === 0) ctx.moveTo(x, y)
                        else ctx.lineTo(x, y)
                    }
                    ctx.closePath()

                    var fc = root.colFace
                    ctx.fillStyle = Qt.rgba(fc.r, fc.g, fc.b, 1)
                    ctx.fill()
                }

                property color _trackColor: root.colFace
                on_TrackColorChanged: requestPaint()
                Component.onCompleted: requestPaint()
            }

            // Hour hand (hollow style - behind tick marks)
            Item {
                anchors.fill: parent
                rotation: -90 + (360 / 12) * ((timeTimer.hours % 12) + timeTimer.minutes / 60)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: (parent.width - 20) / 2
                    width: 72
                    height: 20
                    radius: height / 2
                    color: "transparent"
                    border.color: root.colHourHand
                    border.width: 4
                }
            }

            // Tick lines - hour marks (12)
            Repeater {
                model: 12
                Item {
                    required property int index
                    rotation: 360 / 12 * index
                    anchors.fill: parent

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        width: 18
                        height: 4
                        radius: width / 2
                        color: root.colOnFace
                        opacity: 0.5
                    }
                }
            }

            // Tick lines - minute marks (60)
            Repeater {
                model: 60
                Item {
                    required property int index
                    rotation: 360 / 60 * index
                    anchors.fill: parent

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        width: 7
                        height: 2
                        radius: width / 2
                        color: root.colOnFace
                        opacity: 0.35
                    }
                }
            }

            // Minute hand (medium style)
            Item {
                anchors.fill: parent
                z: 1
                rotation: -90 + (360 / 60) * timeTimer.minutes

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: (parent.width - 12) / 2
                    width: 95
                    height: 12
                    radius: height / 2
                    color: root.colMinuteHand
                }
            }

            // Center dot
            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: root.colFace
                anchors.centerIn: parent
                z: 4
            }

            // Digital time overlay
            Column {
                anchors.centerIn: parent
                spacing: -16
                z: 3

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: timeTimer.hours.toString().padStart(2, "0")
                    color: root.colOnFace
                    font {
                        family: root.fontFamily
                        pixelSize: 68
                        weight: Font.Bold
                        hintingPreference: Font.PreferFullHinting
                    }
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: timeTimer.minutes.toString().padStart(2, "0")
                    color: root.colOnFace
                    font {
                        family: root.fontFamily
                        pixelSize: 68
                        weight: Font.Bold
                        hintingPreference: Font.PreferFullHinting
                    }
                    renderType: Text.NativeRendering
                }
            }

            // Date bubble - Day of month (top-left, pentagon shape)
            Item {
                width: 64
                height: 64
                anchors.left: parent.left
                anchors.top: parent.top
                z: 5

                Canvas {
                    anchors.fill: parent
                    antialiasing: true
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var cx = width / 2
                        var cy = height / 2
                        var r = Math.min(width, height) / 2 - 1
                        var sides = 5
                        var cornerRadius = 8

                        // Calculate pentagon vertices
                        var vertices = []
                        for (var i = 0; i < sides; i++) {
                            var angle = (i / sides) * 2 * Math.PI - Math.PI / 2
                            vertices.push({
                                x: cx + r * Math.cos(angle),
                                y: cy + r * Math.sin(angle)
                            })
                        }

                        // Draw rounded pentagon
                        ctx.beginPath()
                        for (var i = 0; i < sides; i++) {
                            var prev = vertices[(i - 1 + sides) % sides]
                            var curr = vertices[i]
                            var next = vertices[(i + 1) % sides]

                            var dx1 = curr.x - prev.x
                            var dy1 = curr.y - prev.y
                            var len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1)
                            var dx2 = next.x - curr.x
                            var dy2 = next.y - curr.y
                            var len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)

                            var p1x = curr.x - (dx1 / len1) * cornerRadius
                            var p1y = curr.y - (dy1 / len1) * cornerRadius
                            var p2x = curr.x + (dx2 / len2) * cornerRadius
                            var p2y = curr.y + (dy2 / len2) * cornerRadius

                            if (i === 0) ctx.moveTo(p1x, p1y)
                            else ctx.lineTo(p1x, p1y)
                            ctx.quadraticCurveTo(curr.x, curr.y, p2x, p2y)
                        }
                        ctx.closePath()

                        var fc = root.colTertiaryContainer
                        ctx.fillStyle = Qt.rgba(fc.r, fc.g, fc.b, 1)
                        ctx.fill()
                    }
                    Component.onCompleted: requestPaint()
                }

                Text {
                    anchors.centerIn: parent
                    text: timeTimer.day.toString()
                    color: root.colOnTertiaryContainer
                    font {
                        family: root.fontFamily
                        pixelSize: 24
                        weight: Font.Black
                    }
                    renderType: Text.NativeRendering
                }
            }

            // Date bubble - Month (bottom-right, rotated pill)
            Item {
                width: 64
                height: 64
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                z: 5

                Rectangle {
                    anchors.centerIn: parent
                    width: 68
                    height: 44
                    radius: height / 2
                    color: root.colSecondaryContainer
                    rotation: -45
                }

                Text {
                    anchors.centerIn: parent
                    text: (timeTimer.month + 1).toString().padStart(2, "0")
                    color: root.colOnSecondaryContainer
                    font {
                        family: root.fontFamily
                        pixelSize: 24
                        weight: Font.Black
                    }
                    renderType: Text.NativeRendering
                }
            }
        }

        // "Locked" pill
        Rectangle {
            id: lockedPill
            visible: root.showLocked
            anchors.horizontalCenter: parent.horizontalCenter
            width: lockedRow.implicitWidth + 28
            height: 36
            radius: 10
            color: root.colFace

            border.width: 1
            border.color: Qt.rgba(root.colOnFace.r, root.colOnFace.g, root.colOnFace.b, 0.15)

            Row {
                id: lockedRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                    text: "lock"
                    color: root.colOnFace
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }

                Text {
                    text: Tr.tr("locked")
                    color: root.colOnFace
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    // Timer
    Timer {
        id: timeTimer
        property int hours: 0
        property int minutes: 0
        property int seconds: 0
        property int day: 0
        property int month: 0
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            hours = now.getHours()
            minutes = now.getMinutes()
            seconds = now.getSeconds()
            day = now.getDate()
            month = now.getMonth()
        }
    }
}
