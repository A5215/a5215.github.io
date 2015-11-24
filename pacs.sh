#!/bin/bash
#подготовленный список приложений; символ пробела в начале строки обязателен
PACS=""

PACS+=" xorg-server xorg-xinit xorg-server-utils xorg-apps xf86-video-intel mesa mesa-libgl lib32-mesa-libgl libva-intel-driver libva xf86-input-synaptics"
	#X11, video and touchpad
PACS+=" ntfs-3g p7zip udiskie"
	#filesystems
PACS+=" networkmanager network-manager-applet gnome-keyring"
	#network and nm-applet
PACS+=" pulseaudio paprefs pavucontrol alsa-utils pulseaudio-alsa"
	#audio
PACS+=" gtk2 gtk3 lxappearance"
	#GUI settings
PACS+=" awesome lxdm xcompmgr"
	#DM&WM
PACS+=" gnome" #" nautilus gnome-terminal eog gedit gnome-disks file-roller gnome-screenshot gnome-system-monitor"
	#gnome gui apps
PACS+=" vim mc git  vlc firefox gparted"
	#other apps
PACS+=" terminus-font ttf-droid ttf-liberation ttf-dejavu"
	#fonts, fonts, fonts...
pacman -S $PACS

#Autorun services
systemctl  enable NetworkManager
systemctl  enable lxdm

#Configs
#awesome:
#git clone https://github.com/A5215/awesome-config /home/$UNAME/.config/awesome
#layouts in X11
#text='Section "InputClass"
#        Identifier             "keyboard-layout"
#        MatchIsKeyboard        "on"
#        Option "XkbLayout" "us,ru"
#        Option "XkbOptions" "grp:ctrl_shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp"
#EndSection'
#echo "$text" > /etc/X11/xorg.conf.d/00-keyboard-layout.conf

## or add to .xinitrc
# setxkbmap -layout "us, ru" -option "grp:caps_toggle, grp_led:scroll, terminate:ctrl_alt_bksp"
#udisks rules fo polkit
#
#sudo vim /etc/polkit-1/rules.d/50-udisks.rules
text='polkit.addRule(function(action, subject) {
  var YES = polkit.Result.YES;
  var permission = {
    // only required for udisks1:
    "org.freedesktop.udisks.filesystem-mount": YES,
    "org.freedesktop.udisks.filesystem-mount-system-internal": YES,
    "org.freedesktop.udisks.luks-unlock": YES,
    "org.freedesktop.udisks.drive-eject": YES,
    "org.freedesktop.udisks.drive-detach": YES,
    // only required for udisks2:
    "org.freedesktop.udisks2.filesystem-mount": YES,
    "org.freedesktop.udisks2.filesystem-mount-system": YES,
    "org.freedesktop.udisks2.encrypted-unlock": YES,
    "org.freedesktop.udisks2.eject-media": YES,
    "org.freedesktop.udisks2.power-off-drive": YES,
    // required for udisks2 if using udiskie from another seat (e.g. systemd):
    "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
    "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
    "org.freedesktop.udisks2.eject-media-other-seat": YES,
    "org.freedesktop.udisks2.power-off-drive-other-seat": YES
  };
  if (subject.isInGroup("storage")) {
    return permission[action.id];
  }
});'
echo "$text" > /etc/polkit-1/rules.d/50-udisks.rules

exit 0
