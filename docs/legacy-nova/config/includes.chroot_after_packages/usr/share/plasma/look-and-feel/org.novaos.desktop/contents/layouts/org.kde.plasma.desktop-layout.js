// Nova OS default layout: floating bottom taskbar with centered start menu
var panel = new Panel;
panel.location = "bottom";
panel.height = 2 * Math.floor(gridUnit * 2.8 / 2);
panel.floating = true;

panel.addWidget("org.kde.plasma.panelspacer");

var kick = panel.addWidget("org.kde.plasma.kickoff");
kick.currentConfigGroup = ["General"];
kick.writeConfig("icon", "nova-os");

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers",
  "applications:org.kde.dolphin.desktop," +
  "applications:firefox-esr.desktop," +
  "applications:org.kde.konsole.desktop," +
  "applications:org.kde.discover.desktop," +
  "applications:systemsettings.desktop");

panel.addWidget("org.kde.plasma.panelspacer");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");

var ds = desktops();
for (var i = 0; i < ds.length; i++) {
    var d = ds[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/wallpapers/NovaOS/");
}
