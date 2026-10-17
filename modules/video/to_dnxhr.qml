import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    width: 450
    height: 220
    minimumWidth: 450
    maximumWidth: 450
    minimumHeight: 220
    maximumHeight: 220
    visible: true
    title: "Conversion for Resolve"
    color: "#1e1e1e"
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: 20

        Label {
            text: "Conversion in Progress"
            color: "white"
            font.pixelSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            width: parent.width
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            Label {
                text: bridge.current_file
                color: "#cccccc"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            ProgressBar {
                id: control
                value: bridge.progress / 100
                Layout.fillWidth: true
                
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 12
                    color: "#333333"
                    radius: 6
                }

                contentItem: Item {
                    Rectangle {
                        width: control.visualPosition * parent.width
                        height: parent.height
                        color: "#CBA6F7"
                        radius: 6
                    }
                }
            }
            
            Label {
                text: Math.round(bridge.progress) + "%"
                color: "white"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Cancel"
                Layout.alignment: Qt.AlignHCenter
                onClicked: bridge.cancel_conversion()
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 35
                    color: parent.down ? "#cc4444" : "#444444"
                    radius: 6
                }
            }
        }
    }
}
