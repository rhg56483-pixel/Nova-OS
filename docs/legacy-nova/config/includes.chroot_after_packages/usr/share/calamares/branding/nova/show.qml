import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation
    Timer { interval: 6000; running: true; repeat: true; onTriggered: presentation.goToNextSlide() }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0b1d3a"
            Text { anchors.centerIn: parent; color: "white"; font.pixelSize: 36
                   text: "Nova OS\nمرحبًا بك • Welcome"; horizontalAlignment: Text.AlignHCenter } }
    }
    Slide {
        Rectangle { anchors.fill: parent; color: "#0b1d3a"
            Text { anchors.centerIn: parent; color: "white"; font.pixelSize: 30
                   text: "KDE Plasma • عربي / English • VirtualBox Ready"; horizontalAlignment: Text.AlignHCenter } }
    }
}
