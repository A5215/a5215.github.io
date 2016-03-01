#!/bin/bash
#mkdir /mnt/repo && mount -rL REPO /mnt/repo && ./mnt/repo/install/vbox.sh

#####################

read -p "This is dangerous operation. Press [Enter] to continue."
CLEARDISK='/dev/sda' 		#PLEASE choose disk carefully.
MNT=$CLEARDISK'1' 		#link to our volume
MNTPOINT='/mnt/arch'
PACS=" p7zip networkmanager mc git openssh" #virtualbox-guest-utils
function chroot_ops {
GRUBMNT='/dev/sda'			#GRUB will be here
UNAME='u1' 				#username
HNAME='arch-v' 				#hostname
UGROUPS="sys,wheel,video,audio,storage" #user groups


	sed -i 's/#en_US.UTF-8/en_US.UTF-8/'   /etc/locale.gen
	sed -i 's/#ru_RU.UTF-8/ru_RU.UTF-8/'   /etc/locale.gen
	echo LANG=en_US.UTF-8 >                /etc/locale.conf
	echo KEYMAP=ru >>                      /etc/vconsole
	echo FONT=cyr-sun16 >>                 /etc/vconsole
	echo $HNAME >                          /etc/hostname
	sed -i "/localhost/s/$/\t$HNAME/"      /etc/hosts
	sed -i "/root ALL/s/$/\n$UNAME ALL=(ALL) ALL/" /etc/sudoers
	locale-gen
	export LANG=en_US.UTF-8
	ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
	hwclock --systohc --localtime
	mkinitcpio -p linux
	grub-install --target=i386-pc --recheck $GRUBMNT
	sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/'   /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	useradd -m -s /bin/bash -g users -G $UGROUPS $UNAME
	#echo "enter root password"
	#passwd
	echo "enter user password"
	passwd $UNAME
	#драйверы для vbox
	#echo  vboxguest >> /etc/modules-load.d/virtualbox.conf
	#echo  vboxsf >> /etc/modules-load.d/virtualbox.conf
	#echo  vboxvideo >> /etc/modules-load.d/virtualbox.conf
	echo blacklist i2c_piix4 > /etc/modprobe.d/modprobe.conf
	#systemctl enable vboxservice.service
	systemctl enable NetworkManager
#TODO	git clone https://github.com/a5215/migration.git ~/migration
}
export -f chroot_ops

lspci | grep VirtualBox && #VBox check
parted $CLEARDISK mklabel msdos &&
parted $CLEARDISK mkpart primary ext4 1MiB 100% &&
mkfs.ext4 $MNT -L archvol &&
sed -i 's/Server = http/## Server = http/' /etc/pacman.d/mirrorlist &&
sed -i '$ a\\nServer = file:///mnt/repo/archrepo/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
sed -i '$ a\\nServer = http://mirror.yandex.ru/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist &&
mkdir $MNTPOINT && mount $MNT $MNTPOINT &&
mkdir /mnt/repo && mount -rL REPO /mnt/repo &&
pacman -Syy &&
pacstrap $MNTPOINT base base-devel grub $PACS &&
genfstab -L -p $MNTPOINT >> $MNTPOINT/etc/fstab &&
arch-chroot $MNTPOINT  /bin/bash -c chroot_ops

exit 0
