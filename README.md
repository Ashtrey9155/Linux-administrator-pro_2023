# Linux-administrator-pro_2023

## Оглавление

- ## Linux Administrator _ Lesson #3
- ## Linux Administrator _ Lesson #4

## Linux Administrator _ Lesson #3

```
Домашнее задание

Для выполнения домашнего задания используйте методичку
Работа с LVM https://drive.google.com/file/d/1DMxzJ6ctD0-I0My-iJJEGaeLDnIs13zj/view?usp=share_link
Что нужно сделать?
на имеющемся образе (centos/7 1804.2)
https://gitlab.com/otus_linux/stands-03-lvm
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

- уменьшить том под / до 8G
- выделить том под /home
- выделить том под /var (/var - сделать в mirror)
- для /home - сделать том для снэпшотов
- прописать монтирование в fstab (попробовать с разными опциями и разными файловыми системами на выбор)
- Работа со снапшотами:
  - сгенерировать файлы в /home/
  - снять снэпшот
  - удалить часть файлов
  - восстановиться со снэпшота
    (залоггировать работу можно утилитой script, скриншотами и т.п.)
Задание со звездочкой*
На нашей куче дисков попробовать поставить btrfs/zfs:
 - с кешем и снэпшотами
 - разметить здесь каталог /opt
 - Если возникнут вопросы, обращайтесь к студентам, преподавателям и наставникам в канал группы в Slack.

```

<details><summary>

`уменьшить том под / до 8G`

</summary>
	
```
	
Будем выполнять данную операцию при помощи утилиты <b>xfsdump</b>. 
Для начала освободим раздел sdb.
Удалим поочереди логические тома через <b>lvremove</b>, далее удалим логическую группу <b>vgremove /dev/otus</b>, удалим физическую группу pvremove.

Скопируем все данные с / раздела в /mnt:
[root@otuslinux ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
[root@otuslinux ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done [root@otuslinux ~]# chroot /mnt/
[root@otuslinux ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done


[vagrant@lvm ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:7    0 37.5G  0 lvm  
sdb                       8:16   0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
├─vg0-mirror_rmeta_0    253:2    0    4M  0 lvm  
│ └─vg0-mirror          253:6    0  816M  0 lvm  
└─vg0-mirror_rimage_0   253:3    0  816M  0 lvm  
  └─vg0-mirror          253:6    0  816M  0 lvm  
sde                       8:64   0    1G  0 disk 
├─vg0-mirror_rmeta_1    253:4    0    4M  0 lvm  
│ └─vg0-mirror          253:6    0  816M  0 lvm  
└─vg0-mirror_rimage_1   253:5    0  816M  0 lvm  
  └─vg0-mirror          253:6    0  816M  0 lvm  
[vagrant@lvm ~]$ df -hT
Filesystem                  Type      Size  Used Avail Use% Mounted on
/dev/mapper/vg_root-lv_root xfs        10G  843M  9.2G   9% /
devtmpfs                    devtmpfs  110M     0  110M   0% /dev
tmpfs                       tmpfs     118M     0  118M   0% /dev/shm
tmpfs                       tmpfs     118M  4.6M  114M   4% /run
tmpfs                       tmpfs     118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                   xfs      1014M   61M  954M   7% /boot
tmpfs                       tmpfs      24M     0   24M   0% /run/user/1000
[vagrant@lvm ~]$ 

 Теперь нужно изменить размер старой VG и вернуть на него рут. Для этого удаляем старйй LV размеров в 40G и создаем новый на 8G:
[root@lvm vagrant]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
[root@lvm vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@lvm vagrant]# 

Теперь в обратно порядке
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol00 /mnt
[root@lvm vagrant]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
... портянка...
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 18 seconds elapsed
xfsrestore: Restore Status: SUCCESS

[root@lvm vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm vagrant]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@lvm /]# reboot
	
```

</details>

<details><summary>

`выделить том под /var (/var - сделать в mirror)`

</summary>
	
```

Очистим разделы sdc, sdd и на их месте сохдадим зеркало под var
[root@lvm /]# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
[root@lvm /]# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created
[root@lvm /]# lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952.00 MiB
  Logical volume "lv_var" created.

Создаем на нем ФС и перемещаем туда /var
[root@lvm /]# mkfs.ext4 /dev/vg
vga_arbiter  vg_root/     vg_var/      
[root@lvm /]# mkfs.ext4 /dev/vg_var/lv_var 
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
60928 inodes, 243712 blocks
12185 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=249561088
8 block groups
32768 blocks per group, 32768 fragments per group
7616 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

[root@lvm /]# mount /dev/vg_var/lv_var /mnt
[root@lvm /]# cp -aR /var/* /mnt/
[root@lvm /]# rsync -avHPSAX /var/ /mnt/
sending incremental file list
./
.updated
            163 100%    0.00kB/s    0:00:00 (xfr#1, ir-chk=1023/1025)

sent 130,609 bytes  received 576 bytes  262,370.00 bytes/sec
total size is 218,939,828  speedup is 1,668.94
[root@lvm /]# 
[root@lvm /]# rm -R /var
rm: descend into directory ‘/var’? ^C
[root@lvm /]# rm -R /var/*
rm: remove directory ‘/var/adm’? y
rm: descend into directory ‘/var/cache’? y
rm: descend into directory ‘/var/cache/ldconfig’? y
rm: remove regular file ‘/var/cache/ldconfig/aux-cache’? ^C
[root@lvm /]# rm -R /var/* -y
rm: invalid option -- 'y'
Try 'rm --help' for more information.
[root@lvm /]# umount /mnt/
[root@lvm /]# mount /dev/vg_var/lv_var /var
[root@lvm /]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
[root@lvm /]# 
	
```


</details>


<details><summary>

`выделить том под /home`

</summary>
	
```

Делаем по аналогии с var
Создаем раздел под Home на VolGroup00
[root@lvm vagrant]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  
sdb                          8:16   0   10G  0 disk 
sdc                          8:32   0    2G  0 disk 
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:4    0  952M  0 lvm  
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  952M  0 lvm  
  └─vg_var-lv_var          253:7    0  952M  0 lvm  /var
sde                          8:64   0    1G  0 disk 

Создаем ФС xfs
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol_Home 
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

Монтируем созданный раздел в /mnt
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /mnt/
Копируем все из /home
[root@lvm vagrant]# cp -aR /home/* /mnt/
Очищаем Home
[root@lvm vagrant]# rm -rf /home/*

[root@lvm vagrant]# umount /mnt
Монтируем новый раздел в Home
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /home/
И создаем запись в fstab
[root@lvm vagrant]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@lvm vagrant]# 
	
```

</details>

<details><summary>

`Попробуем snapshot`

</summary>
		
```

Создадим файлы 
[root@lvm vagrant]# cd /home/
[root@lvm home]# ls
vagrant
[root@lvm home]# touch /home/file{1..20}
[root@lvm home]# ls
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9  vagrant
[root@lvm home]# 

Создадим snapshot:
[root@lvm home]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
[root@lvm home]# 
Удалим несколько файлов:
[root@lvm home]# rm -f /home/file{11..20}
[root@lvm home]# ls
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  vagrant
[root@lvm home]# 
Восстановим из snapshot:
[root@lvm home]# lsof /home
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash    1357 root  cwd    DIR  253,2      152   64 /home
lsof    1520 root  cwd    DIR  253,2      152   64 /home
lsof    1521 root  cwd    DIR  253,2      152   64 /home
[root@lvm home]# cd ..
[root@lvm /]# umount /home
[root@lvm /]# lvconvert --merge /dev/VolGroup00/home_snap
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/LogVol_Home: Merged: 100.00%
[root@lvm /]# mount /home
[root@lvm /]# ls /home/
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9  vagrant
[root@lvm /]# 
	
```

</details>

## Linux Administrator _ Lesson #4

```

Домашнее задание
<b>Практические навыки работы с ZFS</b>
Цель:
Отрабатываем навыки работы с созданием томов export/import и установкой параметров.

определить алгоритм с наилучшим сжатием;
определить настройки pool’a;
найти сообщение от преподавателей.
Результат:
список команд, которыми получен результат с их выводами.

```

<details>
	<summary>	
		Создаём виртуальную машину
	</summary>

```
Создаем Vagrant файл для запуска виртуальной машины:

# -*- mode: ruby -*-
# vim: set ft=ruby :
disk_controller = 'IDE' # MacOS. This setting is OS dependent. Details https://github.com/hashicorp/vagrant/issues/8105


MACHINES = {
  :zfs => {
        :box_name => "centos/7",
        :box_version => "2004.01",
    :disks => {
        :sata1 => {
			:dfile => './sata1.vdi',
            :size => 512,
            :port => 1

        },
        :sata2 => {
            :dfile => './sata2.vdi',
            :size => 512, # Megabytes
            :port => 2
        },
        :sata3 => {
            :dfile => './sata3.vdi',
            :size => 512,
            :port => 3
        },
        :sata4 => {
            :dfile => './sata4.vdi',
            :size => 512, 
            :port => 4
        },
        :sata5 => {
            :dfile => './sata5.vdi',
            :size => 512,
            :port => 5
        },
        :sata6 => {
            :dfile => './sata6.vdi',
            :size => 512,
            :port => 6
        },
        :sata7 => {
            :dfile => './sata7.vdi',
            :size => 512, 
            :port => 7
        },
        :sata8 => {
            :dfile => './sata8.vdi',
            :size => 512, 
            :port => 8
        },
    }
        
  },
}


Vagrant.configure("2") do |config|


  MACHINES.each do |boxname, boxconfig|


      config.vm.define boxname do |box|


        box.vm.box = boxconfig[:box_name]
        box.vm.box_version = boxconfig[:box_version]


        box.vm.host_name = "zfs"


        box.vm.provider :virtualbox do |vb|
              vb.customize ["modifyvm", :id, "--memory", "1024"]
              needsController = false
        boxconfig[:disks].each do |dname, dconf|
              unless File.exist?(dconf[:dfile])
              vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
         needsController =  true
         end
        end
            if needsController == true
                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                boxconfig[:disks].each do |dname, dconf|
                vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                end
             end
          end
        box.vm.provision "shell", inline: <<-SHELL
          #install zfs repo
          yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
          #import gpg key 
          rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
          #install DKMS style packages for correct work ZFS
          yum install -y epel-release kernel-devel zfs
          #change ZFS repo
          yum-config-manager --disable zfs
          yum-config-manager --enable zfs-kmod
          yum install -y zfs
          #Add kernel module zfs
          modprobe zfs
          #install wget
          yum install -y wget
      SHELL


    end
  end
end

```

</details>
	

<details>
	<summary>
		<code>1. Определение алгоритма с наилучшим сжатием</code>
	</summary>
	
		Проверяем наличие дисков командой <b>lsblk</b>
		[root@zfs ~]# lsblk
		NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
		sda      8:0    0   40G  0 disk 
		└─sda1   8:1    0   40G  0 part /
		sdb      8:16   0  512M  0 disk 
		sdc      8:32   0  512M  0 disk 
		sdd      8:48   0  512M  0 disk 
		sde      8:64   0  512M  0 disk 
		sdf      8:80   0  512M  0 disk 
		sdg      8:96   0  512M  0 disk 
		sdh      8:112  0  512M  0 disk 
		sdi      8:128  0  512M  0 disk 
		[root@zfs ~]# 
	
Создадим зеркальные RAID и отобразим что получилось
	
	[root@zfs ~]# zpool create otus1 mirror /dev/sdb /dev/sdc
	[root@zfs ~]# zpool create otus2 mirror /dev/sdd /dev/sde
	[root@zfs ~]# zpool create otus3 mirror /dev/sdf /dev/sdg
	[root@zfs ~]# zpool create otus4 mirror /dev/sdh /dev/sdi
	[root@zfs ~]# zpool list
	NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
	otus1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
	otus2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
	otus3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
	otus4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
	[root@zfs ~]# lsblk
	NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
	sda      8:0    0   40G  0 disk 
	└─sda1   8:1    0   40G  0 part /
	sdb      8:16   0  512M  0 disk 
	├─sdb1   8:17   0  502M  0 part 
	└─sdb9   8:25   0    8M  0 part 
	sdc      8:32   0  512M  0 disk 
	├─sdc1   8:33   0  502M  0 part 
	└─sdc9   8:41   0    8M  0 part 
	sdd      8:48   0  512M  0 disk 
	├─sdd1   8:49   0  502M  0 part 
	└─sdd9   8:57   0    8M  0 part 
	sde      8:64   0  512M  0 disk 
	├─sde1   8:65   0  502M  0 part 
	└─sde9   8:73   0    8M  0 part 
	sdf      8:80   0  512M  0 disk 
	├─sdf1   8:81   0  502M  0 part 
	└─sdf9   8:89   0    8M  0 part 
	sdg      8:96   0  512M  0 disk 
	├─sdg1   8:97   0  502M  0 part 
	└─sdg9   8:105  0    8M  0 part 
	sdh      8:112  0  512M  0 disk 
	├─sdh1   8:113  0  502M  0 part 
	└─sdh9   8:121  0    8M  0 part 
	sdi      8:128  0  512M  0 disk 
	├─sdi1   8:129  0  502M  0 part 
	└─sdi9   8:137  0    8M  0 part 
	[root@zfs ~]# 

Создадим разные алгоритмы сжатия
	
	[root@zfs ~]# zfs set compression=lzjb otus1
	[root@zfs ~]# zfs set compression=lz4 otus2
	[root@zfs ~]# zfs set compression=gzip-9 otus3
	[root@zfs ~]# zfs set compression=zle otus4
	[root@zfs ~]# zfs get all | grep compression
	
	otus1  compression           lzjb                   local
	otus2  compression           lz4                    local
	otus3  compression           gzip-9                 local
	otus4  compression           zle                    local
	[root@zfs ~]# 
	
Мы скачали на каждый диск один и тот же файл и посмотрим сколько места он занимает
	
	[root@zfs ~]# df -h
	Filesystem      Size  Used Avail Use% Mounted on
	devtmpfs        489M     0  489M   0% /dev
	tmpfs           496M     0  496M   0% /dev/shm
	tmpfs           496M  6.8M  489M   2% /run
	tmpfs           496M     0  496M   0% /sys/fs/cgroup
	/dev/sda1        40G  7.2G   33G  18% /
	tmpfs           100M     0  100M   0% /run/user/1000
	otus1           352M   22M  331M   7% /otus1
	otus2           352M   18M  335M   6% /otus2
	otus3           352M   11M  342M   4% /otus3
	otus4           352M   40M  313M  12% /otus4
	
	[root@zfs ~]# zpool list
	NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
	otus1   480M  21.6M   458M        -         -     0%     4%  1.00x    ONLINE  -
	otus2   480M  17.7M   462M        -         -     0%     3%  1.00x    ONLINE  -
	otus3   480M  10.8M   469M        -         -     0%     2%  1.00x    ONLINE  -
	otus4   480M  39.1M   441M        -         -     0%     8%  1.00x    ONLINE  -

	[root@zfs ~]# ls -l /otus*
	/otus1:
	total 22036
	-rw-r--r--. 1 root root 40894017 Jan  2 09:19 pg2600.converter.log

	/otus2:
	total 17981
	-rw-r--r--. 1 root root 40894017 Jan  2 09:19 pg2600.converter.log

	/otus3:
	total 10953
	-rw-r--r--. 1 root root 40894017 Jan  2 09:19 pg2600.converter.log

	/otus4:
	total 39963
	-rw-r--r--. 1 root root 40894017 Jan  2 09:19 pg2600.converter.log
	[root@zfs ~]# 

	
</details>
	
<details>
	<summary>
		<code>2. Определение настроек пула</code>
	</summary>
	
Скачаем архив в корневой каталог
	
	wget -O archive.tar.gz
	
Распакуем
	
	[root@zfs ~]# tar -xzvf archive.tar.gz
	zpoolexport/
	zpoolexport/filea
	zpoolexport/fileb
	
Импортируем 
	
	[root@zfs ~]# zpool import -d zpoolexport/
	   pool: otus
	     id: 6554193320433390805
	  state: ONLINE
	 action: The pool can be imported using its name or numeric identifier.
	 config:

		otus                         ONLINE
		  mirror-0                   ONLINE
		    /root/zpoolexport/filea  ONLINE
		    /root/zpoolexport/fileb  ONLINE
	[root@zfs ~]# 
	[root@zfs ~]# 
	[root@zfs ~]# zpool import -d zpoolexport/ otus
	[root@zfs ~]# zpool status
	  pool: otus
	 state: ONLINE
	  scan: none requested
	config:

		NAME                         STATE     READ WRITE CKSUM
		otus                         ONLINE       0     0     0
		  mirror-0                   ONLINE       0     0     0
		    /root/zpoolexport/filea  ONLINE       0     0     0
		    /root/zpoolexport/fileb  ONLINE       0     0     0

	errors: No known data errors
	
Теперь можем запросить все параметры ФС
	
	zfs get all otus
	
Но портянка будет длинная и поэтому выберем лишь некоторые:
	
	[root@zfs ~]# zfs get available otus
	NAME  PROPERTY   VALUE  SOURCE
	otus  available  350M   -
	[root@zfs ~]# zfs get readonly otus
	NAME  PROPERTY  VALUE   SOURCE
	otus  readonly  off     default
	[root@zfs ~]# zfs get recordsize otus
	NAME  PROPERTY    VALUE    SOURCE
	otus  recordsize  128K     local
	[root@zfs ~]# zfs get compression otus
	NAME  PROPERTY     VALUE     SOURCE
	otus  compression  zle       local
	[root@zfs ~]# 
	[root@zfs ~]# zfs get checksum otus
	NAME  PROPERTY  VALUE      SOURCE
	otus  checksum  sha256     local

</details>
	
<details>
	<summary>
		<code>3. Работа со снапшотом, поиск сообщения от преподавателя</code>
	</summary>
	
Скачаем файл:
	
	wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
	
	Saving to: ‘otus_task2.file’

	100%[==================================================================================================================================================================>] 5,432,736   2.23MB/s   in 2.3s   

	2023-01-22 15:36:10 (2.23 MB/s) - ‘otus_task2.file’ saved [5432736/5432736]
	
	
	[root@zfs ~]# ll
		total 12432
		-rw-------. 1 root root    5570 Apr 30  2020 anaconda-ks.cfg
		-rw-r--r--. 1 root root 7275140 Jan 22 15:20 archive.tar.gz
		-rw-------. 1 root root    5300 Apr 30  2020 original-ks.cfg
		-rw-r--r--. 1 root root 5432736 Jan 22 15:36 otus_task2.file
		drwxr-xr-x. 2 root root      32 May 15  2020 zpoolexport
		[root@zfs ~]# 
	
Восстановим файловую систему из снапшота:
	
	[root@zfs ~]# zfs receive otus/test@today < otus_task2.file
								   
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
								   
	[root@zfs ~]# ll /otus/test/
		total 2590
		-rw-r--r--. 1 root    root          0 May 15  2020 10M.file
		-rw-r--r--. 1 root    root     727040 May 15  2020 cinderella.tar
		-rw-r--r--. 1 root    root         65 May 15  2020 for_examaple.txt
		-rw-r--r--. 1 root    root          0 May 15  2020 homework4.txt
		-rw-r--r--. 1 root    root     309987 May 15  2020 Limbo.txt
		-rw-r--r--. 1 root    root     509836 May 15  2020 Moby_Dick.txt
		drwxr-xr-x. 3 vagrant vagrant       4 Dec 18  2017 task1
		-rw-r--r--. 1 root    root    1209374 May  6  2016 War_and_Peace.txt
		-rw-r--r--. 1 root    root     398635 May 15  2020 world.sql
	[root@zfs ~]# find /otus/test -name "secret_message"
		/otus/test/task1/file_mess/secret_message
								   
Идем по пути и читайем содержимое файла
								   
		[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
		https://github.com/sindresorhus/awesome
								   
Идем по ссылке и попадаем в git репозиторий
								   
Так же можем создать bash скрипт и подключить его в Vagrant файл
								   
Пример такого файла лежит в директории или листинг ниже:
								   
Скрипт test.sh
								   
	root@otuslearn:/home/ashtrey/less_04_zfs/sets_script# cat test.sh
	#install zfs repo
	yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
	#import gpg key 
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
	 #install DKMS style packages for correct work ZFS
	 yum install -y epel-release kernel-devel zfs
	 #change ZFS repo
	 yum-config-manager --disable zfs
	 yum-config-manager --enable zfs-kmod
	 yum install -y zfs
	 #Add kernel module zfs
	 modprobe zfs
	 #install wget
	 yum install -y wget
	root@otuslearn:/home/ashtrey/less_04_zfs/sets_script# 
								   
Vagrant file:
	
	root@otuslearn:/home/ashtrey/less_04_zfs/sets_script# cat Vagrantfile 
	# -*- mode: ruby -*-
	# vim: set ft=ruby :
	disk_controller = 'IDE' # MacOS. This setting is OS dependent. Details https://github.com/hashicorp/vagrant/issues/8105


	MACHINES = {
	   :zfs_script => {
		:box_name => "centos/7", 
		:box_version => "2004.01",    
		:provision => "test.sh",
	   :disks => {
		:sata1 => {
		    :dfile => './sata1.vdi', 
		    :size => 512, 
		    :port => 1

		},
		:sata2 => {
		    :dfile => './sata2.vdi',
		    :size => 512, # Megabytes
		    :port => 2
		},
		:sata3 => {
		    :dfile => './sata3.vdi',
		    :size => 512,
		    :port => 3
		},
		:sata4 => {
		    :dfile => './sata4.vdi',
		    :size => 512, 
		    :port => 4
		},
		:sata5 => {
		    :dfile => './sata5.vdi',
		    :size => 512,
		    :port => 5
		},
		:sata6 => {
		    :dfile => './sata6.vdi',
		    :size => 512,
		    :port => 6
		},
		:sata7 => {
		    :dfile => './sata7.vdi',
		    :size => 512, 
		    :port => 7
		},
		:sata8 => {
		    :dfile => './sata8.vdi',
		    :size => 512, 
		    :port => 8
		},
	    }

	  },
	}


	Vagrant.configure("2") do |config|


	  MACHINES.each do |boxname, boxconfig|


	      config.vm.define boxname do |box|


		box.vm.box = boxconfig[:box_name]
		box.vm.box_version = boxconfig[:box_version]


		box.vm.host_name = "zfs"


		box.vm.provider :virtualbox do |vb|
		      vb.customize ["modifyvm", :id, "--memory", "1024"]
		      needsController = false
		boxconfig[:disks].each do |dname, dconf|
		      unless File.exist?(dconf[:dfile])
		      vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
		 needsController =  true
		 end
		end
		    if needsController == true
			vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
			boxconfig[:disks].each do |dname, dconf|
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
			end
		     end
		  end
		box.vm.provision "shell", path: boxconfig[:provision]


	    end
	  end
	end
	root@otuslearn:/home/ashtrey/less_04_zfs/sets_script# 

