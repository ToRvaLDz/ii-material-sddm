import "../translations.js" as Tr
import M3Shapes
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

TextField {
    id: root

    property color colBackground: "#1c1b1c"
    property color colText: "#cbc5ca"
    property color colPlaceholder: "#948f94"
    property color colAccent: "#bac9d1"
    property color colError: "#ffb4ab"
    property string fontFamily: "Google Sans Flex Medium"
    property int fontSize: 15
    property bool failed: false
    // Newest characters past this count are dropped, keeping the row centred
    // and inside the pill instead of overflowing it.
    property int maxVisibleChars: 9
    property int dotSpacing: 5
    property int dotSize: 15
    readonly property int charCount: Math.min(text.length, maxVisibleChars)
    readonly property int firstCharIndex: text.length - charCount
    readonly property int dotsWidth: charCount > 0 ? charCount * (dotSize + dotSpacing) - dotSpacing : 0
    // Shuffled once, so neighbouring characters rarely share an entry shape.
    // No reactive dependencies, so it evaluates a single time.
    readonly property var shapeQueue: {
        const shapes = [MaterialShape.Slanted, MaterialShape.Arch, MaterialShape.Fan, MaterialShape.Arrow, MaterialShape.SemiCircle, MaterialShape.Triangle, MaterialShape.Diamond, MaterialShape.ClamShell, MaterialShape.Pentagon, MaterialShape.Gem, MaterialShape.Sunny, MaterialShape.VerySunny, MaterialShape.Cookie4Sided, MaterialShape.Ghostish, MaterialShape.SoftBurst];
        for (let i = shapes.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            const swap = shapes[i];
            shapes[i] = shapes[j];
            shapes[j] = swap;
        }
        return shapes;
    }

    function loginFailed() {
        failed = true;
        text = "";
        shakeAnim.restart();
        failedTimer.restart();
    }

    Layout.fillHeight: true
    implicitWidth: 200
    padding: 10
    // The Basic style hides its own placeholder while the control has focus
    // and horizontalAlignment is AlignHCenter. This field is focused from
    // startup and its text is hidden behind the overlay, so the placeholder is
    // drawn in the overlay instead.
    placeholderText: ""
    // The shapes in the overlay do the drawing, so the field's own text is
    // hidden and the caret is switched off. Qt 6 has no caretColor - the caret
    // is drawn in `color` - so leaving the cursor on over transparent text
    // would show nothing anyway.
    color: "transparent"
    echoMode: TextInput.Password
    selectionColor: Qt.alpha(colAccent, 0.35)
    selectedTextColor: "transparent"
    cursorVisible: false
    inputMethodHints: Qt.ImhSensitiveData

    font {
        family: root.fontFamily
        pixelSize: root.fontSize
        hintingPreference: Font.PreferFullHinting
    }

    // Decorative: the real value stays in the TextField for screen readers.
    Item {
        id: dotLayer

        anchors.fill: parent
        clip: true
        Accessible.ignored: true

        Text {
            anchors.centerIn: parent
            visible: root.text.length === 0
            text: root.failed ? Tr.tr("incorrect_password") : Tr.tr("enter_password")
            color: root.colPlaceholder
            font: root.font
            renderType: Text.NativeRendering
        }

        ListView {
            id: charList

            anchors.centerIn: parent
            width: root.dotsWidth
            height: root.dotSize
            orientation: Qt.Horizontal
            spacing: root.dotSpacing
            interactive: false
            // split("") on an empty string yields [""], which would render one
            // bogus dot, so the empty case is guarded here.
            model: root.text.length > 0 ? root.text.split("") : []

            // The slot width is fixed, so the row's growth is smoothed here
            // rather than by animating each delegate's width every frame.
            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1, 1, 1]
                }
            }

            // index is injected by the ListView into PasswordChar's own
            // required property, so it is not redeclared here.
            delegate: PasswordChar {
                entryShape: root.shapeQueue[(root.firstCharIndex + index) % root.shapeQueue.length]
                shapeColor: root.colAccent
                charSize: root.dotSize
                active: charList.visible
            }
        }
    }

    Timer {
        id: failedTimer

        interval: 2000
        onTriggered: root.failed = false
    }

    SequentialAnimation {
        id: shakeAnim

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -30
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 30
            duration: 50
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -15
            duration: 40
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 15
            duration: 40
        }

        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 0
            duration: 30
        }
    }

    transform: Translate {
        id: shakeTranslate

        x: 0
    }

    Rectangle {
        anchors.fill: parent
        radius: 9999
        color: "transparent"
        border.width: root.failed ? 1 : 0
        border.color: root.colError

        Behavior on border.width {
            NumberAnimation {
                duration: 200
            }
        }
    }

    background: Rectangle {
        color: colBackground
        radius: 9999
    }
}
