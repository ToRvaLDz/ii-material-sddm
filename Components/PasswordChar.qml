import M3Shapes
import QtQuick

/**
 * One password character: a Material Shape that pops in, holds, morphs into a
 * dot, then settles. Choreography ported from midnight-shell's PolkitDialog
 * CharItem (components/PolkitDialog.qml).
 *
 * Sized so the entry shape never overlaps its neighbours: implicitSize is
 * charSize * entryScale, the peak renders at scale 1 and the resting dot at
 * 1 / entryScale, which lands back on exactly charSize. The slot itself stays a
 * fixed charSize wide, so no relayout happens per frame while typing.
 */
Item {
    id: char

    required property int index

    // Shape revealed on entry; morphs to a dot once the animation settles.
    property int entryShape: MaterialShape.Circle
    property color shapeColor: "#ffffff"
    property real charSize: 15
    // How much larger the entry shape gets before it collapses to the dot.
    property real entryScale: 1.25
    // Off when the list is hidden, so the entry animation stops ticking.
    property bool active: true

    implicitWidth: char.charSize
    implicitHeight: char.charSize

    ListView.onRemove: {
        entryAnim.stop();
        removeAnim.start();
    }

    MaterialShape {
        id: charShape

        anchors.centerIn: parent
        implicitSize: char.charSize * char.entryScale
        shape: char.entryShape
        color: char.shapeColor
        opacity: 0

        Behavior on color {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.88, 0.34, 1, 1, 1]
            }
        }

        // NumberAnimation rather than the Animator types on purpose: the
        // sequence has to stay in lockstep with the `shape` assignment below,
        // which is a custom property the Animator types cannot target. A
        // render-thread animation would let the SequentialAnimation advance
        // before the pop had visually finished.
        SequentialAnimation {
            id: entryAnim

            running: char.active

            ParallelAnimation {
                NumberAnimation {
                    target: charShape
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                }

                NumberAnimation {
                    target: charShape
                    property: "scale"
                    from: 0
                    to: 1
                    duration: 350
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
                }
            }

            PauseAnimation {
                duration: 180
            }

            // MaterialShape interpolates a `shape` change itself, so this
            // assignment is what produces the morph into the dot.
            PropertyAction {
                target: charShape
                property: "shape"
                value: MaterialShape.Circle
            }

            NumberAnimation {
                target: charShape
                property: "scale"
                to: 1 / char.entryScale
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
            }
        }

        SequentialAnimation {
            id: removeAnim

            PropertyAction {
                target: char
                property: "ListView.delayRemove"
                value: true
            }

            ParallelAnimation {
                NumberAnimation {
                    target: charShape
                    property: "opacity"
                    to: 0
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                }

                NumberAnimation {
                    target: charShape
                    property: "scale"
                    to: 0.5
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                }
            }

            PropertyAction {
                target: char
                property: "ListView.delayRemove"
                value: false
            }
        }
    }
}
