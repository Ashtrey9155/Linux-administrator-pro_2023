# Linux-administrator-pro_2023

## Оглавление

- #### <a href="#linux-administrator-_-lesson-3-1">Linux Administrator _ Lesson #3</a>
- #### <a href="#linux-administrator-_-lesson-4-1">Linux Administrator _ Lesson #4</a>
- #### <a href="#linux-administrator-_-lesson-5-1">Linux Administrator _ Lesson #5</a>
- #### <a href="#linux-administrator-_-lesson-6-1">Linux Administrator _ Lesson #6</a>
- #### <a href="#linux-administrator-_-lesson-7-1">Linux Administrator _ Lesson #7</a>
- #### <a href="#linux-administrator-_-lesson-8-1">Linux Administrator _ Lesson #8</a>
- #### <a href="#linux-administrator-_-lesson-9-1">Linux Administrator _ Lesson #9</a>
- #### <a href="#linux-administrator-_-lesson-10-1">Linux Administrator _ Lesson #10</a>
- #### <a href="#linux-administrator-_-lesson-11-1">Linux Administrator _ Lesson #11</a>
- #### <a href="#linux-administrator-_-lesson-12-1">Linux Administrator _ Lesson #12</a>
- #### <a href="#linux-administrator-_-lesson-13-1">Linux Administrator _ Lesson #13</a>
- #### <a href="#linux-administrator-_-lesson-14-1">Linux Administrator _ Lesson #14</a>
- #### <a href="#linux-administrator-_-lesson-15-1">Linux Administrator _ Lesson #15</a>
- #### <a href="#linux-administrator-_-lesson-16-1">Linux Administrator _ Lesson #16</a>
- #### <a href="#linux-administrator-_-lesson-17-1">Linux Administrator _ Lesson #17</a>
- #### <a href="#linux-administrator-_-lesson-18-1">Linux Administrator _ Lesson #18</a>
- #### <a href="#linux-administrator-_-lesson-19-1">Linux Administrator _ Lesson #19</a>

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

	Домашнее задание
	
	### Практические навыки работы с ZFS ###
	
	Цель:
	Отрабатываем навыки работы с созданием томов export/import и установкой параметров.

	определить алгоритм с наилучшим сжатием;
	определить настройки pool’a;
	найти сообщение от преподавателей.
	Результат:
	список команд, которыми получен результат с их выводами.

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
		

	Далее, ищем в каталоге /otus/test файл с именем "secret_message":
								   
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
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--	type', 'hdd', '--medium', dconf[:dfile]]
			end
		     end
		  end
		box.vm.provision "shell", path: boxconfig[:provision]


	    end
	  end
	end
	root@otuslearn:/home/ashtrey/less_04_zfs/sets_script#
	
</details>

## Linux Administrator _ Lesson #5
	
Домашнее задание

	Vagrant стенд для NFS
	Цель:
	развернуть сервис NFS и подключить к нему клиента;
	
<details>
	<summary>	
		Создаём виртуальные машины server и client
	</summary>

Для начала создадим Vagrant файл, который создаст нам 2 ВМ:
	
		MACHINES = {
	   :server => {
		:box_name => "centos/7",
		:box_version => "2004.01",
		:provision => "init.sh",
		:ip => "192.168.56.41",

	   },
	   :client => {
		:box_name => "centos/7",
		:box_version => "2004.01",
		:provision => "init.sh",
		:ip => "192.168.56.42",
	   },
	}


	Vagrant.configure("2") do |config|

		MACHINES.each do |boxname, boxconfig|

			config.vm.define boxname do |box|

				box.vm.box = boxconfig[:box_name]
				box.vm.box_version = boxconfig[:box_version]
				box.vm.host_name = boxname
				box.vm.network "private_network", ip: boxconfig[:ip]

				box.vm.provider :virtualbox do |vb|
					vb.customize ["modifyvm", :id, "--memory", "1024"]
				end

				box.vm.provision "shell",
					name: "configuretion_from_shell",
					path: boxconfig[:provision]
				end
			end

		end

Результатом запуска vagrant up будут запущены две ВМ машины:
	
	ashtrey@otuslearn:~/less_05_nfs$ vboxmanage list vms
	"less_05_nfs_server_1674641508898_17420" {0bb01387-145d-4f0d-85d2-c74fc8e524cd}
	"less_05_nfs_client_1674641649496_53544" {df7ccb0a-355d-44d6-8dd5-1f56dde80f7a}
	ashtrey@otuslearn:~/less_05_nfs$ 
	ashtrey@otuslearn:~/less_05_nfs$ vagrant status
	Current machine states:

	server                    running (virtualbox)
	client                    running (virtualbox)

</details>
	
<details>
	<summary>	
		2. Настройка ВМ
	</summary>

Установим утилиты
	
	[root@server ~]# yum install nfs-utils
	Loaded plugins: fastestmirror
	Determining fastest mirrors
	 * base: mirror.besthosting.ua
	 * extras: mirror.besthosting.ua
	 * updates: mirror.besthosting.ua

	###########------ много текста ------###########
	
	Running transaction
	  Updating   : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64    1/2                                                                                                                                          
	  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64       2/2                                                                                                                                                  
	  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.2.x86_64      1/2                                                                                                                                                 
	  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64       2/2                                                                                                                                                  

	Updated:
	  nfs-utils.x86_64 1:1.3.0-0.68.el7.2                                                                                                                                                                       

	Complete!
	[root@server ~]# 
	
Включаем firewall
	
	[root@server ~]# systemctl status firewalld
	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
	   Active: inactive (dead)
	     Docs: man:firewalld(1)
	[root@server ~]# systemctl enable firewalld --now
	Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
	Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
	[root@server ~]# systemctl status firewalld
	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
	   Active: active (running) since Wed 2023-01-25 10:40:35 UTC; 2s ago
	     Docs: man:firewalld(1)
	 Main PID: 3725 (firewalld)
	   CGroup: /system.slice/firewalld.service
		   └─3725 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

	Jan 25 10:40:35 server systemd[1]: Starting firewalld - dynamic firewall daemon...
	Jan 25 10:40:35 server systemd[1]: Started firewalld - dynamic firewall daemon.
	Jan 25 10:40:35 server firewalld[3725]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please consider...abling it now.
	Hint: Some lines were ellipsized, use -l to show in full.
	
 Разрешаем в firewall доступ к сервисам NFS
	
	[root@server ~]# firewall-cmd --add-service="nfs3"
	success
	[root@server ~]# firewall-cmd --add-service="rpc-bind"
	success
	[root@server ~]# firewall-cmd  --permanent firewall-cmd --reload
	usage: see firewall-cmd man page
	firewall-cmd: error: unrecognized arguments: firewall-cmd
	[root@server ~]# firewall-cmd  --permanent firewall-cmd
	usage: see firewall-cmd man page
	firewall-cmd: error: unrecognized arguments: firewall-cmd
	[root@server ~]# firewall-cmd   --reload
	success
	
 Включаем сервер NFS
	
	[root@server ~]# systemctl enable nfs --now
	Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
	
Создадим дирикторию которая будет экспортирована, сменим владельца и дадим ей все права
	
	[root@server ~]# mkdir -p /srv/share/upload
	[root@server ~]# chown -R nfsnobody:nfsnobody /srv/share

	[root@server ~]# ls -lat /srv/share/
	total 0
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 .
	drwxr-xr-x. 3 root      root      19 Jan 26 15:49 ..
	drwxr-xr-x. 2 nfsnobody nfsnobody  6 Jan 26 15:49 upload
	
	[root@server ~]# chmod 0777 /srv/share/upload
	[root@server ~]# ls -lat /srv/share/
	total 0
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 .
	drwxr-xr-x. 3 root      root      19 Jan 26 15:49 ..
	drwxrwxrwx. 2 nfsnobody nfsnobody  6 Jan 26 15:49 upload
	
Создадим файл и подготовим к экспорту
	
	[root@server ~]# echo "/srv/share 192.168.50.11/32(rw,sync,root_squash)" >> /etc/exports
	
	[root@server ~]# exportfs -r
	[root@server ~]# exportfs -s
	/srv/share  192.168.56.42/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
	
!!! Как оказалось этого не достаточно, на клиенте ни чего не монтируется и на fstab ругается консоль, после не продолжительного гугления был найден выход. Это правка firewall и самого файла fstab:
	
	[root@server ~]# systemctl enable rpcbind
	[root@server ~]# systemctl enable nfs-server
	[root@server ~]# systemctl start rpcbind
	[root@server ~]# systemctl start nfs-server
	[root@server ~]# firewall-cmd --permanent --add-port=111/tcp
	success
	[root@server ~]# firewall-cmd --permanent --add-port=20048/tcp
	success
	[root@server ~]# firewall-cmd --permanent --zone=public --add-service=nfs
	success
	[root@server ~]# 
	[root@server ~]# firewall-cmd --permanent --zone=public --add-service=mountd
	success
	[root@server ~]# firewall-cmd --permanent --zone=public --add-service=rpc-bind
	success
	[root@server ~]# firewall-cmd --permanent --add-port=2049/udp
success
	[root@server ~]# firewall-cmd --reload
	success
	
	
Настроим клента:
	
	yum install nfs-utils
	
	systemctl enable firewalld --now
	
	echo "192.168.56.41:/srv/share/ /mnt/ nfs rw,sync,hard,intr 0 0" >> /etc/fstab
	systemctl daemon-reload
	systemctl restart remote-fs.target
	
	[root@client ~]# cat /etc/fstab 

	#
	# /etc/fstab
	# Created by anaconda on Thu Apr 30 22:04:55 2020
	#
	# Accessible filesystems, by reference, are maintained under '/dev/disk'
	# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
	#
	UUID=1c419d6c-5064-4a2b-953c-05b2c67edb15 /                       xfs     defaults        0 0
	/swapfile none swap defaults 0 0
	#VAGRANT-BEGIN
	# The contents below are automatically generated by Vagrant. Do not modify.
	#VAGRANT-END
	192.168.56.41:/srv/share/ /mnt/ nfs rw,sync,hard,intr 0 0
	

На стороне клиента проверил командой mount -a 
	
	TCP
	[root@client ~]# mount | grep /mnt
	192.168.56.41:/srv/share on /mnt type nfs4 (rw,relatime,sync,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.56.42,local_lock=none,addr=192.168.56.41)
	UDP
	[root@client ~]# mount | grep /mnt
	192.168.56.41:/srv/share/ on /mnt type nfs (rw,relatime,sync,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.41,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.41)
	
Проверяем что монтирование директории прошло удачно и возможно создать файлы на обоих сторонах:
	
	[root@server ~]# cd /srv/share/upload/
	[root@server upload]# touch check_file
	[root@server upload]# ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	[root@server upload]# 
	
	[root@client ~]# cd /mnt
	[root@client mnt]# ls -la
	total 0
	drwxr-xr-x.  3 nfsnobody nfsnobody  20 Jan 26 15:49 .
	dr-xr-xr-x. 18 root      root      255 Jan 25 10:14 ..
	drwxrwxrwx.  2 nfsnobody nfsnobody  24 Jan 27 20:59 upload
	[root@client mnt]# cd upload/
	[root@client upload]# ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 24 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	[root@client upload]# touch client_file
	[root@client upload]# ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	[root@client upload]# 
	
Перезагружаем клиента и проверяем наличие файлов:
	
	[root@client upload]# reboot
	Connection to 127.0.0.1 closed by remote host.
	Connection to 127.0.0.1 closed.
	ashtrey@otuslearn:~/less_05_nfs$ vagrant ssh client
	Last login: Fri Jan 27 20:40:23 2023 from 10.0.2.2
	[vagrant@client ~]$ 
	[vagrant@client ~]$ 
	[vagrant@client ~]$ ls -la /mnt/upload/
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	[vagrant@client ~]$ 
	
Перезагружаем сервер, проверяем что все на месте:
	
	[root@server upload]# reboot
	Connection to 127.0.0.1 closed by remote host.
	Connection to 127.0.0.1 closed.
	ashtrey@otuslearn:~/less_05_nfs$ vagrant ssh server
	Last login: Fri Jan 27 20:45:28 2023 from 10.0.2.2
	[vagrant@server ~]$ ls -la /srv/share/upload/
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 26 15:49 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	[vagrant@server ~]$ 
	
Проверяем статусы:
	
	[vagrant@server ~]$ systemctl status nfs
	● nfs-server.service - NFS server and services
	   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
	  Drop-In: /run/systemd/generator/nfs-server.service.d
		   └─order-with-mounts.conf
	   Active: active (exited) since Fri 2023-01-27 21:04:11 UTC; 1min 28s ago
	  Process: 808 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
	  Process: 788 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
	  Process: 785 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
	 Main PID: 788 (code=exited, status=0/SUCCESS)
	   CGroup: /system.slice/nfs-server.service
	
	[vagrant@server ~]$ systemctl status firewalld
	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
	   Active: active (running) since Fri 2023-01-27 21:04:08 UTC; 1min 38s ago
	     Docs: man:firewalld(1)
	 Main PID: 407 (firewalld)
	   CGroup: /system.slice/firewalld.service
		   └─407 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

	[vagrant@server ~]$ sudo exportfs -s
	/srv/share  192.168.56.42/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

	[vagrant@server ~]$ showmount -a 192.168.56.41
	All mount points on 192.168.56.41:
	[vagrant@server ~]$ 

Переходим снова к клиенту и совершаем финальные проверки:
	
	[vagrant@client ~]$ sudo reboot
	Connection to 127.0.0.1 closed by remote host.
	Connection to 127.0.0.1 closed.
	ashtrey@otuslearn:~/less_05_nfs$ vagrant ssh client
	Last login: Fri Jan 27 21:02:27 2023 from 10.0.2.2
	[vagrant@client ~]$ sudo -i
	[root@client ~]# showmount -a 192.168.56.41
	All mount points on 192.168.56.41:
	[root@client ~]# showmount -a 192.168.56.42
	All mount points on 192.168.56.42:
	[root@client ~]# mount | grep mnt
	192.168.56.41:/srv/share on /mnt type nfs4 (rw,relatime,sync,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.56.42,local_lock=none,addr=192.168.56.41)
	[root@client ~]# cd /mnt/
	[root@client mnt]# cd upload/
	[root@client upload]# ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 27 20:59 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 39 Jan 27 21:10 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	[root@client upload]# touch final_check
	[root@client upload]# ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 62 Jan 27 21:10 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 39 Jan 27 21:10 ..
	-rw-r--r--. 1 root      root       0 Jan 27 20:59 check_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 20:59 client_file
	-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 27 21:10 final_check
	[root@client upload]# 
	
На этом считаем что стенд настроен верно. Откорректируем Vagrant файл для автоматической настройки.
Файлы-скрипты:
	
	ashtrey@otuslearn:~/less_05_nfs$ ls
	init_client.sh  init_server.sh  init.sh  Vagrantfile
	ashtrey@otuslearn:~/less_05_nfs$ cat init_server.sh 
	#!/bin/bash

	selinuxenabled && setenforce 0

	cat > /etc/selinux/config <<SCPT
	SELINUX = disabled
	SELINUXTYPE = targeted
	SCPT

	yum install nfs-utils -y

	systemctl enable firewalld --now
	firewall-cmd --add-service="nfs3"
	firewall-cmd --add-service="rpc-bind"

	firewall-cmd   --reload

	systemctl enable nfs --now

	mkdir -p /srv/share/upload
	chown -R nfsnobody:nfsnobody /srv/share
	chmod 0777 /srv/share/upload

	echo "/srv/share 192.168.56.42/32(rw,sync,root_squash)" >> /etc/exports
	exportfs -r

	systemctl enable rpcbind
	systemctl enable nfs-server
	systemctl start rpcbind
	systemctl start nfs-server

	firewall-cmd --permanent --add-port=111/tcp
	firewall-cmd --permanent --add-port=20048/tcp
	firewall-cmd --permanent --zone=public --add-service=nfs
	firewall-cmd --permanent --zone=public --add-service=mountd
	firewall-cmd --permanent --zone=public --add-service=rpc-bind

	firewall-cmd --reload
	ashtrey@otuslearn:~/less_05_nfs$ cat init_client.sh 
	#!/bin/bash

	selinuxenabled && setenforce 0

	cat > /etc/selinux/config <<SCPT
	SELINUX = disabled
	SELINUXTYPE = targeted
	SCPT

	yum install nfs-utils  -y

	systemctl enable firewalld --now

	echo "192.168.56.41:/srv/share/ /mnt/ nfs rw,sync,hard,intr 0 0" >> /etc/fstab

	systemctl daemon-reload
	systemctl restart remote-fs.target
	ashtrey@otuslearn:~/less_05_nfs$ 

	
	
Теперь разрушим наши машины и пересоберем с учетом автонастройки:
	
	ashtrey@otuslearn:~/less_05_nfs$ vagrant destroy -f
	==> client: Forcing shutdown of VM...
	==> client: Destroying VM and associated drives...
	==> server: Forcing shutdown of VM...
	==> server: Destroying VM and associated drives...
	ashtrey@otuslearn:~/less_05_nfs$ 
	
	ashtrey@otuslearn:~/less_05_nfs$ vagrant up
	############### тут длинная партянка ###############
	
Проверим что все прошло удачно. Сначала на клиенте:
	
	ashtrey@otuslearn:~/less_05_nfs$ vagrant ssh client
	[vagrant@client ~]$ mount | grep /mnt
	192.168.56.41:/srv/share on /mnt type nfs4 (rw,relatime,sync,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.56.42,local_lock=none,addr=192.168.56.41)
	[vagrant@client ~]$ cd /mnt/upload/
	[vagrant@client upload]$ ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody  6 Jan 27 21:47 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 27 21:47 ..
	[vagrant@client upload]$ touch test_client_file
	[vagrant@client upload]$ ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 30 Jan 27 21:49 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 27 21:47 ..
	-rw-rw-r--. 1 vagrant   vagrant    0 Jan 27 21:49 test_client_file
	
На клиенте все хорошо. Автоматически все примонтировалось и дает создавать файлы.
Теперь проверим на сервере:
	
	[vagrant@client upload]$ exit
	logout
	Connection to 127.0.0.1 closed.
	ashtrey@otuslearn:~/less_05_nfs$ vagrant ssh server
	[vagrant@server ~]$ cd /srv/share/upload/
	[vagrant@server upload]$ ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 30 Jan 27 21:49 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 27 21:47 ..
	-rw-rw-r--. 1 vagrant   vagrant    0 Jan 27 21:49 test_client_file
	[vagrant@server upload]$ touch test_server_file
	[vagrant@server upload]$ ls -la
	total 0
	drwxrwxrwx. 2 nfsnobody nfsnobody 54 Jan 27 21:51 .
	drwxr-xr-x. 3 nfsnobody nfsnobody 20 Jan 27 21:47 ..
	-rw-rw-r--. 1 vagrant   vagrant    0 Jan 27 21:49 test_client_file
	-rw-rw-r--. 1 vagrant   vagrant    0 Jan 27 21:51 test_server_file
	[vagrant@server upload]$ 
	
Все настроено и работает исправно!
	
	
</details>

## Linux Administrator _ Lesson #6

Домашнее задание
Размещаем свой RPM в своем репозитории

1. Cоздать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями);
создать свой репо и разместить там свой RPM;
2. Реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.
3. Задание со звездочкой* реализовать дополнительно пакет через docker
В чат ДЗ отправьте ссылку на ваш git-репозиторий . Обычно мы проверяем ДЗ в течение 48 часов.
Если возникнут вопросы, обращайтесь к студентам, преподавателям и наставникам в канал группы в Slack.
Удачи при выполнении!

<details>
	<summary>
		1. Cоздать свой RPM
	</summary>
	
Сборку своего RPM будем производить на ВМ Centos 8. Для начала установим набор утилит:

	yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc
	
Создал дерево каталогов для сборки:

	[root@otuslesson ~]# rpmdev-setuptree

	[root@otuslesson ~]# tree /root/rpmbuild/
	/root/rpmbuild/
	├── BUILD
	├── RPMS
	├── SOURCES
	├── SPECS
	└── SRPMS

	5 directories, 0 files
	
Для примера возьмём пакет NGINX и соберем его с поддержкой протокола HTTPS

Загрузим SRPM пакет NGINX для дальнейшей сборки:

	[root@otuslesson ~]# wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.22.1-1.el8.ngx.src.rpm
	
Установим пакет:

	[root@otuslesson ~]# rpm -Uvh nginx-1.22.1-1.el8.ngx.src.rpm

Установим заранее все зависимости:

	[root@otuslesson ~]# yum-builddep rpmbuild/SPECS/nginx.spec
	
Теперь поправим наш SPEC файл

	%build
	./configure %{BASE_CONFIGURE_ARGS} \
	    --with-cc-opt="%{WITH_CC_OPT}" \
	    --with-ld-opt="%{WITH_LD_OPT}" \
	    --with-debug \
	    --with-http_ssl_module  <--- мы добавили эту строку
	    
Теперь соберем пакет:

	[root@otuslesson ~]# rpmbuild -bb rpmbuild/SPECS/nginx.spec
	
	####### A FEW MOMENTS LATER #######
	
	Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
	Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/nginx-1.22.1-1.el8.ngx.x86_64
	Wrote: /root/rpmbuild/RPMS/x86_64/nginx-1.22.1-1.el8.ngx.x86_64.rpm
	Wrote: /root/rpmbuild/RPMS/x86_64/nginx-debuginfo-1.22.1-1.el8.ngx.x86_64.rpm
	Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.8ezpAF
	+ umask 022
	+ cd /root/rpmbuild/BUILD
	+ cd nginx-1.22.1
	+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.22.1-1.el8.ngx.x86_64
	+ exit 0
	
Проверяем что все собралось:


	[root@otuslesson ~]# tree rpmbuild/
	......
	├── BUILDROOT
	├── RPMS
	│   └── x86_64
	│       ├── nginx-1.22.1-1.el8.ngx.x86_64.rpm
	│       └── nginx-debuginfo-1.22.1-1.el8.ngx.x86_64.rpm
	├── SOURCES
	│   ├── logrotate
	│   ├── nginx-1.22.1.tar.gz
	│   ├── nginx.check-reload.sh
	│   ├── nginx.conf
	│   ├── nginx.copyright
	│   ├── nginx-debug.service
	│   ├── nginx.default.conf
	│   ├── nginx.service
	│   ├── nginx.suse.logrotate
	│   └── nginx.upgrade.sh
	├── SPECS
	│   └── nginx.spec
	└── SRPMS


Установим наш локальный пакет:

	[root@otuslesson x86_64]# yum localinstall -y nginx-1.22.1-1.el8.ngx.x86_64.rpm
	
Запустим и проверим статус:

	[root@otuslesson x86_64]# systemctl start nginx
	[root@otuslesson x86_64]# systemctl status nginx
	● nginx.service - nginx - high performance web server
	   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	   Active: active (running) since Sun 2023-01-29 20:26:12 UTC; 13s ago
	     Docs: http://nginx.org/en/docs/
	  Process: 39760 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
	 Main PID: 39761 (nginx)
	    Tasks: 3 (limit: 24912)
	   Memory: 3.0M
	   CGroup: /system.slice/nginx.service
		   ├─39761 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
		   ├─39762 nginx: worker process
		   └─39763 nginx: worker process

	Jan 29 20:26:12 otuslesson.02 systemd[1]: Starting nginx - high performance web server...
	Jan 29 20:26:12 otuslesson.02 systemd[1]: Started nginx - high performance web server.
	[root@otuslesson x86_64]# 
	
	
</details>

<details>
	<summary>
		2. Cоздать свой репо и разместить там свой RPM
	</summary>
	
В каталоге NGINX создал дирикторию repo, скопировал туда свои репо-файлы, а так же еще один из домашки по ссылке. И инициировал репозиторий командой:
	
	[root@otuslesson nginx]# createrepo /usr/share/nginx/html/repo/
	Directory walk started
	Directory walk done - 3 packages
	Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
	Preparing sqlite DBs
	Pool started (with 5 workers)
	Pool finished
	[root@otuslesson nginx]# 
	
По заданию настроили прозрачность листинга каталога:
	
	[root@otuslesson nginx]# cat /etc/nginx/conf.d/default.conf 
	server {
	    listen       80;
	    server_name  localhost;

	    #access_log  /var/log/nginx/host.access.log  main;

	    location / {
		root   /usr/share/nginx/html;
		index  index.html index.htm;
		autoindex on;
	    }
	
Тепереь проверим сонфиг и перезапкстим NGONX:
	
	[root@otuslesson nginx]# nginx -t
	nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	nginx: configuration file /etc/nginx/nginx.conf test is successful
	[root@otuslesson nginx]# nginx -s reload
	
Проверяем с помощью утилиты Curl доступность репо по ссылке:
	
	[root@otuslesson nginx]# curl -a http://localhost/repo/
	<html>
	<head><title>Index of /repo/</title></head>
	<body>
	<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
	<a href="repodata/">repodata/</a>                                          31-Jan-2023 13:24                   -
	<a href="nginx-1.22.1-1.el8.ngx.x86_64.rpm">nginx-1.22.1-1.el8.ngx.x86_64.rpm</a>                  30-Jan-2023 22:11              847380
	<a href="nginx-debuginfo-1.22.1-1.el8.ngx.x86_64.rpm">nginx-debuginfo-1.22.1-1.el8.ngx.x86_64.rpm</a>        30-Jan-2023 22:11             2400168
	<a href="percona-orchestrator-3.2.6-2.el8.x86_64.rpm">percona-orchestrator-3.2.6-2.el8.x86_64.rpm</a>        16-Feb-2022 15:57             5222976
	</pre><hr></body>
	</html>
	
Проверим в работе:
	
	[root@otuslesson nginx]# cat /etc/yum.repos.d/otuslearn.repo
	[otuslearn]
	name=otuslearn-linux
	baseurl=http://localhost/repo
	gpgcheck=0
	enabled=1
	[root@otuslesson nginx]# 

	[root@otuslesson nginx]# yum repolist enabled | grep otus
	otuslearn                       otuslearn-linux
	
	[root@otuslesson nginx]# yum list | grep otus
	otuslearn-linux                                 1.3 MB/s | 3.3 kB     00:00  
	percona-orchestrator.x86_64                            2:3.2.6-2.el8                                          otuslearn 
	 
	[root@otuslesson nginx]# yum install nginx
	Last metadata expiration check: 0:01:07 ago on Tue 31 Jan 2023 01:39:50 PM UTC.
	Package nginx-1:1.22.1-1.el8.ngx.x86_64 is already installed.
	Dependencies resolved.
	Nothing to do.
	Complete!

	[root@otuslesson nginx]# yum install percona-orchestrator.x86_64
	Last metadata expiration check: 0:02:24 ago on Tue 31 Jan 2023 01:39:50 PM UTC.
	Dependencies resolved.
	============================================================================================================================================================================================================
	 Package                                                  Architecture                               Version                                            Repository                                     Size
	============================================================================================================================================================================================================
	Installing:
	 percona-orchestrator                                     x86_64                                     2:3.2.6-2.el8                                      otuslearn                                     5.0 M
	Installing dependencies:
	 jq                                                       x86_64                                     1.5-12.el8                                         appstream                                     161 k
	 oniguruma                                                x86_64                                     6.8.2-2.el8                                        appstream                                     187 k

	Transaction Summary
	============================================================================================================================================================================================================
	Install  3 Packages

	Total download size: 5.3 M
	Installed size: 17 M
	Is this ok [y/N]: 
	
	Видим, что нам предлагается установить пакет из нашего локального репозитория
	

</details>
	
Можно было бы вытащить NGINX наружу, но мой сервер за НАТ (вопрос решился DyDSN), сервер на Ubuntu на нем вируталка и вот на виртуалке NGINX. Делать проброс через 2 хоста как то не хочется, если нужно, могу поднять NGINX на Ubuntu.
	
	
	
## Linux Administrator _ Lesson #7

Домашнее задание:
	
Работа с загрузчиком

1. Попасть в систему без пароля несколькими способами.
2. Установить систему с LVM, после чего переименовать VG.
3. Добавить модуль в initrd.
4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m
В чат ДЗ отправьте ссылку на ваш git-репозиторий . Обычно мы проверяем ДЗ в течение 48 часов.
Если возникнут вопросы, обращайтесь к студентам, преподавателям и наставникам в канал группы в Slack.
Удачи при выполнении!
	
<details>
	<summary>
		1. Попасть в систему без пароля несколькими способами.
	</summary>

Для теста установил CentOS 9 Streem. Опробуем несколько способов сброса пароля.
1. init=/bin/sh
	При загрузке нажимаю "e", попадаю в редактор загрузчика Grub2. В конце строки linux добавил init=/bin/sh
	
	Ctrl+X -> непродолжительная загрузка и попадаю с shell по управлением sh.
	Команда mount дала мне понять что корень смонтирован только на чтение.
	
	Командой mount -o remount,rw /  мне удалось перемонтировать корневую систему на запись.
	 passwd -> ввожу новый пароль для root
	
Меня постигла неудача, причину которой найти не могу, как только я меняю пароль у пользователя root, больше я не могу залогиниться ни как, ни под какими паролями ни старыми ни новыми. Я перепробовал все способы из методички и из сети, все время одно и тоже (((
	
После нескольких попыток, принял решение перейти на бругую ОСь, выбор пал на Убунту (была готовая под рукой), хотя изначально планировал на CentOS 7.
Особо ни чего не поменялось и принялся эксперементировать.
	
Попытка номер 1:
	
	В момент загрузки нажимаем "е" и попадаем в редактор загрузки Граб.
	
	Все что нам надо это найти строку которая начинается со слова "linux" и в конце строки дописать "init=/bin/bash".
	Далее нажимаем ctrl+x и попадаем в bash.
	
	Есть нюанс, корень примонтирован на чтение, делаем следующее
	
	mount -o remount,rw /
	
	Теперь можно менять пароль
	
	passwd
	
	New pass
	Retry new pass
	
	/sbin/reboot -f
	
Попытка номер 2:
	
	Особо не отличается от первой, но есть нюанс
	
	В той же строке там же в конце мы пишем "rw init=/bin/bash".
	
	И все, корень примонтирован сразу на запись, далее меняем пароль, но не будем перезагружаться, а запустим процесс загрузки дальше
	
	exec /sbin/init
	
Попытка номер 3:
	
	Способ тоже не сильно отличается от первых, есть нюанс )))
	Нужно с конце все тойже строки прописать "rd.break"
	
	Далее нужно перемонтировать директорию "mount -o remount,rw /sysroot", не корневую, а "/sysroot".
	
	Теперь меняем свою корневую директорию на /sysroot
	
	chroot /sysroot
	
	И далее по той же схеме меняем пароль.
	
На этот раз все получилось.
	
	
</details>
	
<details>
	<summary>
		2. Установить систему с LVM, после чего переименовать VG.
	</summary>
	
Загрузились в ВМ на CentOS 7, проверили что VG на месте.
	
	[root@otuslessonboot ~]# lvs
	  LV       VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
	  LogVol00 VolGroup00 -wi-ao---- <37.47g                                                    
	  LogVol01 VolGroup00 -wi-ao----   1.50g       
						 
	[root@otuslessonboot ~]# vgs
	  VG         #PV #LV #SN Attr   VSize   VFree
	  VolGroup00   1   2   0 wz--n- <38.97g    0 
	
	[root@otuslessonboot ~]# pvs
	  PV         VG         Fmt  Attr PSize   PFree
	  /dev/sda3  VolGroup00 lvm2 a--  <38.97g    0 

Меняем название VG:
						  
	[root@otuslessonboot ~]# vgrename VolGroup00 OtusRoot
	  Volume group "VolGroup00" successfully renamed to "OtusRoot"
						 
Теперь необходимо отредактировать /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg
						  
[root@otuslessonboot ~]# vi /etc/fstab 
						  
	# /etc/fstab
	# Created by anaconda on Sat May 12 18:50:26 2018
	#
	# Accessible filesystems, by reference, are maintained under '/dev/disk'
	# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
	#
	/dev/mapper/OtusRoot-LogVol00 /                       xfs     defaults        0 0
	UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
	/dev/mapper/OtusRoot-LogVol01 swap                    swap    defaults        0 0
	#VAGRANT-BEGIN
	# The contents below are automatically generated by Vagrant. Do not modify.
	#VAGRANT-END
						  
[root@otuslessonboot ~]# vi /etc/default/grub

	GRUB_TIMEOUT=1
	GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
	GRUB_DEFAULT=saved
	GRUB_DISABLE_SUBMENU=true
	GRUB_TERMINAL_OUTPUT="console"
	GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=OtusRoot/LogVol00 rd.lvm.lv=OtusRoot/LogVol01 rhgb quiet"
	GRUB_DISABLE_RECOVERY="true"
						  
[root@otuslessonboot ~]# vi /boot/grub2/grub.cfg
						  
	Весь вывод не буду выкатывать, а только продемонстрирую что была замена названия
						  
	[root@otuslessonboot ~]# cat /boot/grub2/grub.cfg | grep VolGroup00
		linux16 /vmlinuz-3.10.0-862.2.3.el7.x86_64 root=/dev/mapper/VolGroup00-LogVol00 ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VolGroup00/LogVol00 rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet 
	[root@otuslessonboot ~]# vi /boot/grub2/grub.cfg
	[root@otuslessonboot ~]# 
	[root@otuslessonboot ~]# 
	[root@otuslessonboot ~]# cat /boot/grub2/grub.cfg | grep VolGroup00
	[root@otuslessonboot ~]# 

Запустим утилиту, что бы пересоздать initrd
[root@otuslessonboot ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
						  
	************************
						  
	*** No early-microcode cpio image needed ***
	*** Store current command line parameters ***
	*** Creating image file ***
	*** Creating image file done ***
	*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
						  
	Готово!!!
						  
Перезагрузимся для проверки, что все прошло удачно

	[root@otuslessonboot ~]# reboot
	Connection to 127.0.0.1 closed by remote host.
	Connection to 127.0.0.1 closed.
						  
	
И ВМ завис, пришлось Вагранту сказать halt и поднять машину заново, после чего подключился по ssh
						  
	ashtrey@otuslearn:~/less_07_boot$ vagrant ssh
	Last login: Sat Feb  4 15:28:59 2023 from 10.0.2.2
	[vagrant@otuslessonboot ~]$ sudo -i
	[root@otuslessonboot ~]# vgs
	  VG       #PV #LV #SN Attr   VSize   VFree
	  OtusRoot   1   2   0 wz--n- <38.97g    0 
	[root@otuslessonboot ~]# 
	
	
</details>
		
<details>
	<summary>
		3. Добавить модуль в initrd.
	</summary>

Проделал все шаги по методичке, как итог все получилось. Увидел в загрузке свою картинку https://disk.yandex.ru/i/ruwl4pi24RapfQ

</details>

<details>
	<summary>
		4. Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
	</summary>


</details>
	
	
## Linux Administrator _ Lesson #8
Домашнее задание: 

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
	
Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig
	
<details>
	<summary>
		1. Написать сервис
	</summary>

Создадим файл с конфигурацией для сервиса
[root@otuslesson ~]# vi /etc/sysconfig/watchlog
	
	# Configuration file for my watchlog service
	# Place it to /etc/sysconfig

	# File and word in that file that we will be monit
	WORD="ALERT"
	LOG=/var/log/watchlog.log
	[root@otuslesson sysconfig]# 
	
Теперь создадим файл с логом /var/log/watchlog.log
	
	[root@otuslesson sysconfig]# touch /var/log/watchlog.log
	[root@otuslesson sysconfig]# cat << EOF > /var/log/watchlog.log
	> lksdlfsdf
	> sdfs
	> sdf
	> s
	> 
	> 
	> ssdfsdfsd
	> sdf
	> sdf
	> sdfsdsdfsdfsdf
	> sfdfsfd
	> asasd ‘ALERT
	> ‘ALERT’
	> ALERT’
	> 
	> ALERT
	> EOF
	
	[root@otuslesson sysconfig]# cat /var/log/watchlog.log
	lksdlfsdf
	sdfs
	sdf
	s


	ssdfsdfsd
	sdf
	sdf
	sdfsdsdfsdfsdf
	sfdfsfd
	asasd ‘ALERT
	‘ALERT’
	ALERT’

	ALERT
	[root@otuslesson sysconfig]# 
	
Напишем скрипт:
	
	[root@otuslesson sysconfig]# touch /opt/watchlog.sh
	[root@otuslesson sysconfig]# cat <<EOF > /opt/watchlog.sh
		#!/bin/bash

		WORD=$1
		LOG=$2
		DATE=`date`

		if grep $WORD $LOG &> /dev/null
		then
		logger "$DATE: I found word, Master!"
		else
		exit 0
		fi
		EOF

	[root@otuslesson sysconfig]# cat /opt/watchlog.sh
	#!/bin/bash

	WORD=$1
	LOG=$2
	DATE=`date`

	if grep $WORD $LOG &> /dev/null
	then
	logger "$DATE: I found word, Master!"
	else
	exit 0
	fi
	[root@otuslesson sysconfig]# 
	
Добавим нашему файлу прав на исполнение
	
	[root@otuslesson sysconfig]# chmod +x /opt/watchlog.sh
	[root@otuslesson sysconfig]# 
	[root@otuslesson sysconfig]# ls -lat /opt/ | grep wat*
		-rwxr-xr-x.  1 root root 131 Feb  5 14:45 watchlog.sh
	[root@otuslesson sysconfig]# 
	
Создадим юнит для сервиса:
	
	Вспомним, что все копии системных файлов системы располагаются в /lib/systemd/system, 
	но там что то создавать или править не стоит, поэтому есть дириктория /etc/systemd/system, 
	у нее приоритет выше и наши созданные Юниты лучше расположить там
	
	[root@otuslesson system]# cat watchlog.*
	[Unit]
	Description=My watchlog service

	[Service]
	#Type=oneshot
	Type=simple
	EnvironmentFile=-/etc/sysconfig/watchlog
	ExecStart=/opt/watchlog.sh $WORD $LOG
	[Unit]
	Description=Run watchlog script every 30 second

	
	
	[Timer]
	# Run every 30 second
	OnUnitActiveSec=30
	Unit=watchlog.service

	[Install]
	WantedBy=multi-user.target
	[root@otuslesson system]# 

Далее нужно включить наш таймер и запустить
	
	[root@otuslesson system]# systemctl enable watchlog.timer 
	
	[root@otuslesson system]# systemctl start watchlog.timer 
	[root@otuslesson system]# tail -f /var/log/messages
	Feb  5 18:34:27 localhost root[4594]: Sun Feb  5 18:34:27 UTC 2023: I found word, Master!
	Feb  5 18:34:27 localhost systemd[1]: watchlog.service: Succeeded.
	Feb  5 18:35:49 localhost systemd[1]: Reloading.
	Feb  5 18:36:28 localhost systemd[1]: Started Run watchlog script every 30 second.
	Feb  5 18:36:28 localhost systemd[1]: Started My watchlog service.
	Feb  5 18:36:28 localhost root[4629]: start /opt/watchlog.sh
	Feb  5 18:36:28 localhost root[4630]: ALERT
	Feb  5 18:36:28 localhost root[4631]: /var/log/watchlog.log
	Feb  5 18:36:28 localhost root[4634]: Sun Feb  5 18:36:28 UTC 2023: I found word, Master!
	Feb  5 18:36:28 localhost systemd[1]: watchlog.service: Succeeded.
	
Как итог таймер работает
	
</details>
	
<details>
	<summary>
		2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл
	</summary>
	
Устанавливаем spawn-fcgi и необходимые для него пакеты: 
	
	[root@otuslesson yum.repos.d]# yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
	
[root@otuslesson yum.repos.d]# cd /etc/rc.d/init.d/
[root@otuslesson init.d]# ls
functions  README  spawn-fcgi
	
Немного подправим файл spawn-fcgi, раскомменитруем строки:
	
	[root@otuslesson init.d]# vi /etc/sysconfig/spawn-fcgi
	[root@otuslesson init.d]# cat /etc/sysconfig/spawn-fcgi
	# You must set some working options before the "spawn-fcgi" service will work.
	# If SOCKET points to a file, then this file is cleaned up by the init script.
	#
	# See spawn-fcgi(1) for all possible options.
	#
	# Example :
	SOCKET=/var/run/php-fcgi.sock
	OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"

	[root@otuslesson init.d]# 
	
Далее создадим service для запуска spawn-fcgi
	
	[root@otuslesson system]# touch spawn-fcgi.service
	[root@otuslesson system]# vi spawn-fcgi.service 
	[root@otuslesson system]# systemctl status spawn-fcgi.service 
	● spawn-fcgi.service - Spawn-fcgi startup service by Otus
	   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
	   Active: inactive (dead)
	
	[root@otuslesson system]# systemctl enable spawn-fcgi.service 
	Synchronizing state of spawn-fcgi.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
	Executing: /usr/lib/systemd/systemd-sysv-install enable spawn-fcgi
	Created symlink /etc/systemd/system/multi-user.target.wants/spawn-fcgi.service → /etc/systemd/system/spawn-fcgi.service.
	[root@otuslesson system]# 
	
	[root@otuslesson system]# systemctl start spawn-fcgi.service 
	[root@otuslesson system]# systemctl status spawn-fcgi.service 
	● spawn-fcgi.service - Spawn-fcgi startup service by Otus
	   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: disabled)
	   Active: active (running) since Mon 2023-02-06 08:55:51 UTC; 4s ago
	 Main PID: 28152 (php-cgi)
	    Tasks: 33 (limit: 24912)
	   Memory: 18.4M
	   CGroup: /system.slice/spawn-fcgi.service
		   ├─28152 /usr/bin/php-cgi
		   ├─28160 /usr/bin/php-cgi
		   ├─28161 /usr/bin/php-cgi
		   ├─28162 /usr/bin/php-cgi
		   ├─28163 /usr/bin/php-cgi
		   ├─28164 /usr/bin/php-cgi
		   ├─28165 /usr/bin/php-cgi
		   ├─28166 /usr/bin/php-cgi
		   ├─28167 /usr/bin/php-cgi
		   ├─28168 /usr/bin/php-cgi
		   ├─28169 /usr/bin/php-cgi
		   ├─28170 /usr/bin/php-cgi
		   ├─28171 /usr/bin/php-cgi
		   ├─28172 /usr/bin/php-cgi
		   ├─28173 /usr/bin/php-cgi
		   ├─28174 /usr/bin/php-cgi
		   ├─28175 /usr/bin/php-cgi
		   ├─28176 /usr/bin/php-cgi
		   ├─28177 /usr/bin/php-cgi
		   ├─28178 /usr/bin/php-cgi
		   ├─28179 /usr/bin/php-cgi
		   ├─28180 /usr/bin/php-cgi
		   ├─28181 /usr/bin/php-cgi
		   ├─28182 /usr/bin/php-cgi
		   ├─28183 /usr/bin/php-cgi
		   ├─28184 /usr/bin/php-cgi
		   ├─28185 /usr/bin/php-cgi
		   ├─28186 /usr/bin/php-cgi
		   ├─28187 /usr/bin/php-cgi
		   ├─28188 /usr/bin/php-cgi
		   ├─28189 /usr/bin/php-cgi
		   ├─28190 /usr/bin/php-cgi
		   └─28191 /usr/bin/php-cgi

	Feb 06 08:55:51 otuslesson.08 systemd[1]: Started Spawn-fcgi startup service by Otus.

	
</details>
	
<details>
	<summary>
		3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
	</summary>
	
Для начала скопируем имеющийся Юнит
	
>	[root@otuslesson system]# cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/
	
И добавим в него строку EnvironmentFile=/etc/sysconfig/httpd-%I, %I - параметр будет подставляться из шаблона для запуска сервиса
	
Теперь создадим файлы с опциями:
	
>	[root@otuslesson system]# touch /etc/sysconfig/httpd-first 
	
>	[root@otuslesson system]# touch /etc/sysconfig/httpd-second
	
	[root@otuslesson system]# cat /etc/sysconfig/httpd-*
	# /etc/sysconfig/httpd-first
	OPTIONS=-f conf/first.conf
	
	# /etc/sysconfig/httpd-second
	OPTIONS=-f conf/second.conf
	
	[root@otuslesson conf]# systemctl start httpd@first
	[root@otuslesson conf]# systemctl start httpd@second
	[root@otuslesson conf]# ss -tnulp | grep httpd
	tcp     LISTEN   0        128                    *:8080                *:*       users:(("httpd",pid=31368,fd=4),("httpd",pid=31367,fd=4),("httpd",pid=31366,fd=4),("httpd",pid=31365,fd=4),("httpd",pid=31363,fd=4))
	tcp     LISTEN   0        128                    *:80                  *:*       users:(("httpd",pid=31145,fd=4),("httpd",pid=31144,fd=4),("httpd",pid=31143,fd=4),("httpd",pid=31142,fd=4),("httpd",pid=31140,fd=4))
	[root@otuslesson conf]# 
	
	
	[root@otuslesson conf]# systemctl status | grep httpd@
           │   │ └─31610 grep --color=auto httpd@
             │ ├─httpd@second.service
             │ └─httpd@first.service
</details>

	
## Linux Administrator _ Lesson #9
	
Домашнее задание
	
Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
Необходимая информация в письме:

1. Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
2. Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
3. Ошибки веб-сервера/приложения c момента последнего запуска;
4. Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
5. Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
	
В письме должен быть прописан обрабатываемый временной диапазон.
	
Начнем с выбора нужной информации

<details>
	<summary>
		1. Получим список всех IP адресов
	</summary>
	
	[root@otuslesson ~]# cat access-4560-644067.log | cut -d ' ' -f 1 | uniq -c | sort -nr | head -n 10
	     39 109.236.252.130
	     36 212.57.117.19
	     33 188.43.241.106
	     17 217.118.66.161
	     17 185.6.8.9
	     16 95.165.18.146
	     16 148.251.223.21
	     12 62.210.252.196
	     12 185.142.236.35
	     12 162.243.13.195
	[root@otuslesson ~]# 
	
	Получили ТОП 10

</details>

<details>
	<summary>
		2. Список ссылок
	</summary>
	
	[root@otuslesson ~]# cat access-4560-644067.log  | cut -d " " -f 11 | sort -n | uniq -c -d | sort -nr
	    498 "-"
	     73 "https://dbadmins.ru/"
	     15 "https://dbadmins.ru/2016/10/26/%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5-%D1%81%D0%B5%D1%82%D0%B5%D0%B2%D1%8B%D1%85-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B5%D0%BA-%D0%B4%D0%BB%D1%8F-oracle-rac/"
	     14 "https://dbadmins.ru/2016/10/17/%D0%9F%D1%80%D0%BE%D0%B4%D0%BE%D0%BB%D0%B6%D0%B0%D0%B5%D0%BC-%D1%8D%D0%BA%D1%81%D0%BF%D0%B5%D1%80%D0%B8%D0%BC%D0%B5%D0%BD%D1%82%D1%8B-%D1%81-lacp/"
	     11 uct="-"
	      4 "https://dbadmins.ru/wp-content/themes/llorix-one-lite/css/font-awesome.min.css?ver=4.4.0"
	      4 "http://dbadmins.ru/"
	      3 "https://dbadmins.ru/wp-content/themes/llorix-one-lite/style.css?ver=1.0.0"
	      2 "https://dbadmins.ru/2016/12/14/virtualenv-%D0%B4%D0%BB%D1%8F-%D0%BF%D0%BB%D0%B0%D0%B3%D0%B8%D0%BD%D0%BE%D0%B2-python-scrappy-%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82-%D0%BD%D0%B0-debian-jessie/"
	      2 "http://dbadmins.ru/wp-content/plugins/uploadify/readme.txt"
	      2 "http://dbadmins.ru/wp-content/plugins/uploadify/includes/check.php"
	      2 "http://dbadmins.ru/wp-admin/admin-post.php?page=301bulkoptions"
	      2 "http://dbadmins.ru/wp-admin/admin-ajax.php?page=301bulkoptions"
	      2 "http://dbadmins.ru/1"
	      2 "http://dbadmins.ru"
	[root@otuslesson ~]# 
	
	Как можем заметить нам попались и пустые запросы
	
</details>
	
<details>
	<summary>
		3. Ошибки обычно хранятся в errorlog, будем уточнять
	</summary>
	
</details>
	
<details>
	<summary>
		4. Список всех кодов HTTP ответа с указанием их кол-ва
	</summary>
	
	[root@otuslesson ~]# cat access-4560-644067.log  | cut -d " " -f 9 | sort -n | uniq -c -d | sort -nr
	    498 200
	     95 301
	     51 404
	     11 "-"
	      7 400
	      3 500
	      2 499
	[root@otuslesson ~]# 

</details>
	
	В итоге я собрал скрипт и запустил его через cron: * * * * * root /usr/bin/flock -w 600 /var/tmp/lesson09.lock /root/lesson09.sh
	
	```
	
		#!/bin/bash
		#echo '0' > ./lastDate.txt
		fileName="/root/access-4560-644067.log"
		lastDateFile='./lastDate.txt'
		outputFile='./outputFile.txt'


		#Очистим файл
		echo '' > $outputFile

		function title {
			echo '
		############################################
		####		' $1'
		############################################
		#count	#
			' >> $outputFile
		}

		function getIpAddresses() {
			title 'Топ ip адресов:'
			sed -n $startCount',$p' $fileName | cut -d ' ' -f 1 | uniq -c | sort -nr | head -n 10 >> $outputFile
			getUrls
		}

		function getUrls() {
			title 'Топ URL'
			sed -n $startCount',$p' $fileName  | cut -d " " -f 11 | sort -n | uniq -c -d | sort -nr >> $outputFile
			getErrors
		}

		function getErrors() {
			title 'Топ ошибок'
			echo "This is not a error files" >> $outputFile
			getCodes
		}

		function getCodes() {
			title 'Топ кодов:'
			sed -n $startCount',$p' $fileName  | cut -d " " -f 9 | sort -n | uniq -c -d | sort -nr >> $outputFile
		}

		############################################

		function getLastDate() {
			sed -n '$'p $fileName | cut -d ' ' -f 4 | cut -d '[' -f 2 > $lastDateFile
		}

		function getFirstDate() {
			firstDate=$(sed -n "$startCount"p $fileName | cut -d ' ' -f 4 | cut -d '[' -f 2)
			lastDate=$(sed -n '$'p $fileName | cut -d ' ' -f 4 | cut -d '[' -f 2)
			title 'Отчет сформирован с '$firstDate' по '$lastDate
		}

		function readFromLastDate() {
			if [ -f "$lastDateFile" ]; then
				lastDate=$(<$lastDateFile)
				startCount=$(cat $fileName | grep -n $lastDate | awk '{print $1}' | cut -d ':' -f 1)
			else 
				startCount=1
			fi
			echo $startCount
			return $startCount
		}

		function sendEmail() {
			sendmail ashtrey.a@gmail.com < $outputFile
		}

		startCount=$( readFromLastDate )

		getFirstDate
		getIpAddresses
		getLastDate

		sendEmail

	
	```
	
	Пример выполнения скрипта:
	
	[root@otuslesson ~]# cat outputFile.txt 


	############################################
	####		 Отчет сформирован с 14/Aug/2019:04:12:10 по 14/Aug/2019:05:17:39
	############################################
	#count	#


	############################################
	####		 Топ ip адресов:
	############################################
	#count	#

	      3 165.22.19.102
	      1 93.158.167.130
	      1 93.158.167.130
	      1 93.158.167.130
	      1 87.250.233.75
	      1 87.250.233.68
	      1 87.250.233.120
	      1 62.75.198.172
	      1 200.33.155.30
	      1 191.96.41.52

	############################################
	####		 Топ URL
	############################################
	#count	#

	     14 "-"

	############################################
	####		 Топ ошибок
	############################################
	#count	#

	This is not a error files

	############################################
	####		 Топ кодов:
	############################################
	#count	#

	     10 200
	      3 301
	      2 404


## Linux Administrator _ Lesson #10
	
Домашнее задание
	
	Написать свою реализацию ps ax используя анализ /proc
Результат ДЗ - рабочий скрипт который можно запустить
	<details>
	<summary>
		Я использовал анализ превдо дириктории /proc для написания своего ps ax
	</summary>
	
	Для вывода информации я написал отдельные библиотеки и подключил уже в исходном исполняемом файле
	
	[root@otuslesson ~]# ll
	total 48
	-rwxr-xr-x. 1 root root  413 Mar 28 21:47 forkps.sh
	-rwxr-xr-x. 1 root root  247 Mar 28 20:57 getCommandName.sh
	-rwxr-xr-x. 1 root root  242 Mar 28 21:42 getStat.sh
	-rwxr-xr-x. 1 root root  949 Mar 28 21:28 getTotalCpu.sh
	-rwxr-xr-x. 1 root root  597 Mar 28 15:59 getTTY.sh

	[root@otuslesson ~]# cat getCommandName.sh
	#!/bin/bash
	function getCommand {
		PID=$1

		cmdline=$( cat /proc/$PID/cmdline 2>/dev/null | sed -e "s/\x00/ /g")

		if [ -z "$cmdline" ]; then
			cmdline="[$( cat /proc/$PID/status 2>/dev/null | grep Name | awk '{print $2}')]"
		fi
		echo  $cmdline
	}

		
	[root@otuslesson ~]# cat getStat.sh 
	#!/bin/bash
	function getStat {
		PID=$1

		cmdline=$( cat /proc/$PID/cmdline 2>/dev/null | sed -e "s/\x00/ /g")

		if [ "$PID" ]; then
			statusName="$( cat /proc/$PID/status 2>/dev/null | grep State | awk '{print $2}')"
		fi
		echo  $statusName
	}

		
	[root@otuslesson ~]# cat getTotalCpu.sh 
	#!/bin/bash
	function getCpu {
	PID=$1
	if [ -z "$PID" ]; then
	    echo Usage: $0 PID
	    exit 1
	fi

	PROCESS_STAT=($(sed -E 's/\([^)]+\)/X/' "/proc/$PID/stat" 2>/dev/null))

	if [[ -z "$PROCESS_STAT" ]]; then
		exit 1
	fi
	PROCESS_UTIME=${PROCESS_STAT[13]}
	PROCESS_STIME=${PROCESS_STAT[14]}
	PROCESS_STARTTIME=${PROCESS_STAT[21]}
	SYSTEM_UPTIME_SEC=$(tr . ' ' </proc/uptime | awk '{print $1}')

	CLK_TCK=$(getconf CLK_TCK)


	if [[ $PROCESS_UTIME = '' ]]; then
		echo '0:00'
		exit 1
	fi

	let PROCESS_UTIME_SEC="$PROCESS_UTIME / $CLK_TCK"
	let PROCESS_STIME_SEC="$PROCESS_STIME / $CLK_TCK"


	let PROCESS_USAGE_SEC="$PROCESS_UTIME_SEC + $PROCESS_STIME_SEC"

	function convertTime {
		let "hh = $1 / 60"
		mm=$(($1%60))
		if (( "$mm" < 10 )); then 
			mm="0${mm}" 
		fi
		#if (( "$hh" < 10 )); then 
		#	hh="0${hh}" 
		#fi
		result="${hh}:${mm}"
		echo $result
	}

	#echo Total CPU usage is ${PROCESS_USAGE_SEC}s
	echo $( convertTime ${PROCESS_USAGE_SEC} )
	}

				 
	[root@otuslesson ~]# cat getTTY.sh
	#!/bin/bash
	function getTTY {
		PID=$1

		if [ -z "$PID" ]; then
			echo Usage: $0 PID
			exit 1
		fi

		getTty=$(ls -l /proc/$PID/fd/0 2> /dev/null | awk '{print $NF}')

		tty=$getTty

		if [[ $tty =~ ^anon.+$ ]];
			then
				tty=$(echo anon)
			fi

		case $tty in
			/dev/null) tty=$(echo "?");;
			'' ) tty=$(echo "?");;
			anon ) tty=$(echo "?") ;;
			*) tty=$(echo $getTty | sed  's/\/dev\// /') ;;
		esac

		echo $tty
	}
		
		
	Запустим наш fork ps ax
		
	[root@otuslesson ~]# time ./forkps.sh 
	PID      TTY      STAT  TIME    COMMAND
	1         ?        S     0:21    /usr/lib/systemd/systemd --switched-root --system --deserialize 16 
	2         ?        S     0:00    [kthreadd] 
	3         ?        I     0:00    [rcu_gp] 
	4         ?        I     0:00    [rcu_par_gp] 
	6         ?        I     0:00    [kworker/0:0H-kblockd] 
	9         ?        I     0:00    [mm_percpu_wq] 
	10        ?        S     0:02    [ksoftirqd/0] 
	11        ?        R     0:09    [rcu_sched] 
	12        ?        S     0:00    [migration/0] 
	13        ?        S     0:03    [watchdog/0] 
	14        ?        S     0:00    [cpuhp/0] 
	15        ?        S     0:00    [cpuhp/1] 
	16        ?        S     0:01    [watchdog/1] 
	17        ?        S     0:00    [migration/1] 
	18        ?        S     0:00    [ksoftirqd/1] 
	20        ?        I     0:00    [kworker/1:0H] 
	23        ?        S     0:00    [kdevtmpfs] 
	24        ?        I     0:00    [netns] 
	25        ?        S     0:00    [kauditd] 
	26        ?        S     0:00    [khungtaskd] 
	27        ?        S     0:00    [oom_reaper] 
	28        ?        I     0:00    [writeback] 
	29        ?        S     0:00    [kcompactd0] 
	30        ?        S     0:00    [ksmd] 
	31        ?        S     0:16    [khugepaged] 
	32        ?        I     0:00    [crypto] 
	33        ?        I     0:00    [kintegrityd] 
	34        ?        I     0:00    [kblockd] 
	35        ?        I     0:00    [blkcg_punt_bio] 
	36        ?        I     0:00    [tpm_dev_wq] 
	37        ?        I     0:00    [md] 
	38        ?        I     0:00    [edac-poller] 
	39        ?        S     0:00    [watchdogd] 
	40        ?        I     0:00    [pm_wq] 
	56        ?        S     0:00    [kswapd0] 
	149       ?        I     0:00    [kthrotld] 
	150       ?        I     0:00    [acpi_thermal_pm] 
	151       ?        I     0:00    [kmpath_rdacd] 
	152       ?        I     0:00    [kaluad] 
	154       ?        I     0:00    [ipv6_addrconf] 
	155       ?        I     0:00    [kstrp] 
	386       ?        I     0:00    [ata_sff] 
	389       ?        S     0:00    [scsi_eh_0] 
	392       ?        I     0:00    [scsi_tmf_0] 
	394       ?        S     0:00    [scsi_eh_1] 
	397       ?        I     0:00    [scsi_tmf_1] 
	406       ?        I     0:33    [kworker/0:1H-kblockd] 
	415       ?        I     0:11    [kworker/1:1H-kblockd] 
	429       ?        I     0:00    [xfsalloc] 
	430       ?        I     0:00    [xfs_mru_cache] 
	433       ?        I     0:00    [xfs-buf/sda1] 
	434       ?        I     0:00    [xfs-conv/sda1] 
	435       ?        I     0:00    [xfs-cil/sda1] 
	436       ?        I     0:00    [xfs-reclaim/sda] 
	437       ?        I     0:00    [xfs-eofblocks/s] 
	438       ?        I     0:00    [xfs-log/sda1] 
	439       ?        S     0:55    [xfsaild/sda1] 
	524       ?        S     0:06    /usr/lib/systemd/systemd-journald 
	587       ?        S     0:02    /usr/bin/rpcbind -w -f 
	588       ?        S     0:00    /sbin/auditd 
	592       ?        I     0:00    [rpciod] 
	593       ?        I     0:00    [kworker/u5:0] 
	594       ?        I     0:00    [xprtiod] 
	608       ?        S     0:08    /usr/lib/systemd/systemd-udevd 
	629       ?        S     0:03    /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only 
	638       ?        S     2:38    /usr/sbin/irqbalance --foreground 
	642       ?        S     0:00    /usr/lib/polkit-1/polkitd --no-debug 
	644       ?        S     0:03    /usr/sbin/sssd -i --logger=files 
	654       ?        S     0:43    /sbin/rngd -f --fill-watermark=0 
	664       ?        S     0:04    /usr/sbin/chronyd 
	714       ?        S     5:45    /usr/libexec/platform-python -Es /usr/sbin/tuned -l -P 
	722       ?        S     0:00    /usr/sbin/gssproxy -D 
	732       ?        S     0:21    /usr/libexec/sssd/sssd_be --domain implicit_files --uid 0 --gid 0 --logger=files 
	735       ?        S     0:24    /usr/libexec/sssd/sssd_nss --uid 0 --gid 0 --logger=files 
	736       ?        S     0:06    /usr/lib/systemd/systemd-logind 
	739       ?        S     0:04    /usr/sbin/crond -n 
	740       tty1     S     0:00    /sbin/agetty -o -p -- \u --noclear tty1 linux 
	797       ?        S     0:00    /usr/sbin/sshd -D -u0 -oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes256-cbc,aes128-gcm@openssh.com,aes128-ctr,aes128-cbc -oMACs=hmac-s
	826       ?        S     2:36    /usr/sbin/rsyslogd -n 
	3109      ?        S     0:54    /usr/sbin/NetworkManager --no-daemon 
	178040    ?        I     0:05    [kworker/1:3-events] 
	178076    ?        I     0:00    [kworker/u4:0-flush-8:0] 
	178112    ?        S     0:00    sshd: vagrant [priv] 
	178116    ?        S     0:00    /usr/lib/systemd/systemd --user 
	178121    ?        S     0:00    (sd-pam) 
	178129    ?        S     0:02    sshd: vagrant@pts/0 
	178130    pts/0    S     0:00    -bash 
	178155    pts/0    S     0:00    sudo -i 
	178157    pts/0    S     0:00    -bash 
	240541    ?        I     0:01    [kworker/1:1-events] 
	254171    ?        I     0:00    [kworker/0:1-mm_percpu_wq] 
	260080    ?        I     0:00    [kworker/0:0-events] 
	260082    ?        I     0:00    [kworker/u4:1-events_unbound] 
	266007    ?        I     0:00    [kworker/0:2-events] 
	268942    pts/0    S     0:00    /bin/bash ./forkps.sh 
	268943    ?                      [] 
	268944    ?                      [] 
	268945    ?                      [] 

	real	0m2.129s
	user	0m1.498s
	sys	0m1.225s
	[root@otuslesson ~]# 

	Как можем заметить моя реализация работает медленнее оригинала.
</details>
	
## Linux Administrator _ Lesson #11
	
Домашнее задание
	Первые шаги с Ansible
- необходимо использовать модуль yum/apt;
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;
- после установки nginx должен быть в режиме enabled в systemd;
- должен быть использован notify для старта nginx после установки;
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.
	
<details>
	<summary>
		Сначала я написал свой первый playbook, а позже переделал его в роли
	</summary>
	
	По ссылке ниже попадете на GIT со всем содержимым
	https://github.com/Ashtrey9155/Linux-administrator-pro_2023/tree/main/lesson_11_ansible
	
	В доказательство листинг отработанного скрипта:
	
	ashtrey@otuslearn:~/less_11_ansible$ ansible-playbook playbooks/play.yml

	PLAY [NGINX | Install and configure NGINX] **************************************************************************************************************

	TASK [Gathering Facts] **********************************************************************************************************************************
	ok: [nginx]

	TASK [epel : NGINX | Install EPEL Repo package from standart repo] **************************************************************************************
	ok: [nginx]

	TASK [nginx : NGINX | Install NGINX package from EPEL Repo] *********************************************************************************************
	ok: [nginx]

	TASK [nginx : NGINX | Create NGINX config file from temlate] ********************************************************************************************
	ok: [nginx]

	PLAY RECAP **********************************************************************************************************************************************
	nginx                      : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

	ashtrey@otuslearn:~/less_11_ansible$ 
	
	
	Доступный NGINX по 8080 порту:
	
	ashtrey@otuslearn:~/less_11_ansible$ curl http://192.168.56.111:8080
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	    <head>
		<title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
		    /*<\![CDATA[*/
		    body {
			background-color: #fff;
			color: #000;
			font-size: 0.9em;
			font-family: sans-serif,helvetica;
			margin: 0;
			padding: 0;
		    }
		    :link {
		    
		   <!-- далее портянка html -->
		   
	И статус NGINX по запрусу через Ansible:
	
	ashtrey@otuslearn:~/less_11_ansible$ ansible nginx -m systemd -a name=nginx
	nginx | SUCCESS => {
	    "ansible_facts": {
		"discovered_interpreter_python": "/usr/libexec/platform-python"
	    },
	    "changed": false,
	    "name": "nginx",
	    "status": {
		"ActiveEnterTimestamp": "Wed 2023-04-05 19:11:12 UTC",
		"ActiveEnterTimestampMonotonic": "22485276489",
		"ActiveExitTimestampMonotonic": "0",
		"ActiveState": "active",
</details>




## Linux Administrator _ Lesson #12
	
Домашнее задание
	
	Практика с SELinux
	Запустить nginx на нестандартном порту 3-мя разными способами:
		- переключатели setsebool;
		- добавление нестандартного порта в имеющийся тип;
		- формирование и установка модуля SELinux.
	К сдаче:
		README с описанием каждого решения (скриншоты и демонстрация приветствуются).
		Обеспечить работоспособность приложения при включенном selinux.
		развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
		выяснить причину неработоспособности механизма обновления зоны (см. README);
		предложить решение (или решения) для данной проблемы;
		выбрать одно из решений для реализации, предварительно обосновав выбор;
		реализовать выбранное решение и продемонстрировать его работоспособность.
		К сдаче:
		README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
		исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.
		В чат ДЗ отправьте ссылку на ваш git-репозиторий. Обычно мы проверяем ДЗ в течение 48 часов.
		Если возникнут вопросы, обращайтесь к студентам, преподавателям и наставникам в канал группы в Slack.
		Удачи при выполнении!
<details>
	<summary>
		Запустить nginx на нестандартном порту 3-мя разными способами:
	</summary>
	Для начала продемонстрирую, что у меня все установлено и настроено по умолчанию:
	
		[root@otuslesson ~]# systemctl status nginx
		● nginx.service - The nginx HTTP and reverse proxy server
		   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
		   Active: active (running) since Sat 2023-04-08 15:07:14 UTC; 19min ago
		 Main PID: 25473 (nginx)
		    Tasks: 3 (limit: 24912)
		   Memory: 5.4M
		   CGroup: /system.slice/nginx.service
			   ├─25473 nginx: master process /usr/sbin/nginx
			   ├─25474 nginx: worker process
			   └─25475 nginx: worker process

		Apr 08 15:07:14 otuslesson.12.selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
		Apr 08 15:07:14 otuslesson.12.selinux nginx[25470]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
		Apr 08 15:07:14 otuslesson.12.selinux nginx[25470]: nginx: configuration file /etc/nginx/nginx.conf test is successful
		Apr 08 15:07:14 otuslesson.12.selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
		[root@otuslesson ~]# 
		[root@otuslesson ~]# 
		[root@otuslesson ~]# 
		[root@otuslesson ~]# 
		[root@otuslesson ~]# ss -lntp | grep nginx
		LISTEN    0         128                0.0.0.0:80               0.0.0.0:*        users:(("nginx",pid=25475,fd=8),("nginx",pid=25474,fd=8),("nginx",pid=25473,fd=8))
		LISTEN    0         128                   [::]:80                  [::]:*        users:(("nginx",pid=25475,fd=9),("nginx",pid=25474,fd=9),("nginx",pid=25473,fd=9))
		[root@otuslesson ~]# 
		[root@otuslesson ~]# 
		[root@otuslesson ~]# sestatus
		SELinux status:                 enabled
		SELinuxfs mount:                /sys/fs/selinux
		SELinux root directory:         /etc/selinux
		Loaded policy name:             targeted
		Current mode:                   enforcing
		Mode from config file:          enforcing
		Policy MLS status:              enabled
		Policy deny_unknown status:     allowed
		Memory protection checking:     actual (secure)
		Max kernel policy version:      32
		[root@otuslesson ~]# 

	Как можем заметить порт стандартный, все запущено и работает.
	
	Теперь изменим порт nginx и перезапустим его:
	
	[root@otuslesson ~]# vi /etc/nginx/nginx.conf
	[root@otuslesson ~]# cat /etc/nginx/nginx.conf | grep :80
	[root@otuslesson ~]# cat /etc/nginx/nginx.conf | grep :4881
		listen       [::]:4881 default_server;
	[root@otuslesson ~]# service nginx restart
	Redirecting to /bin/systemctl restart nginx.service
	Job for nginx.service failed because the control process exited with error code.
	See "systemctl status nginx.service" and "journalctl -xe" for details.
	[root@otuslesson ~]# 
	
	Вот теперь NGINX не стартует.
	
	
	Проверяем встроенный firewall и что файл конфигурации nginx коректен:
	
	[root@otuslesson ~]# systemctl status firewalld
	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
	   Active: inactive (dead)
	     Docs: man:firewalld(1)
	[root@otuslesson ~]# nginx -t
	nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	nginx: configuration file /etc/nginx/nginx.conf test is successful
	[root@otuslesson ~]# 
	
	
	Режим работы selinux:
	
	[root@otuslesson ~]# getenforce
	Enforcing
	
	
	В логах находим строку с блокировкой порта:
	
	[root@otuslesson ~]# tail /var/log/audit/audit.log
	type=PROCTITLE msg=audit(1680968404.652:1297): proctitle=2F7573722F7362696E2F6E67696E78002D74
	type=SERVICE_START msg=audit(1680968404.656:1298): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
	
	type=AVC msg=audit(1680968489.302:1299): avc:  denied  { name_bind } for  pid=26381 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
	
	type=SYSCALL msg=audit(1680968489.302:1299): arch=c000003e syscall=49 success=no exit=-13 a0=8 a1=563b01d25ba8 a2=10 a3=7fff20b40d70 items=0 ppid=1 pid=26381 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
	
	type=PROCTITLE msg=audit(1680968489.302:1299): proctitle=2F7573722F7362696E2F6E67696E78002D74
	
	type=SERVICE_START msg=audit(1680968489.307:1300): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
	
	type=AVC msg=audit(1680968789.312:1301): avc:  denied  { name_bind } for  pid=26408 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
	
	
	Воспользуемся утилитой audit2why:
	
	[root@otuslesson ~]# grep 1680968789.312:1301 /var/log/audit/audit.log | audit2why
	type=AVC msg=audit(1680968789.312:1301): avc:  denied  { name_bind } for  pid=26408 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

		Was caused by:
		The boolean nis_enabled was set incorrectly. 
		Description:
		Allow nis to enabled

		Allow access by executing:
		# setsebool -P nis_enabled 1
	[root@otuslesson ~]# 
	
	Выпоним предложенную рекомендацию:
	
	[root@otuslesson ~]# setsebool -P nis_enabled 1
	[root@otuslesson ~]# systemctl restart nginx
	[root@otuslesson ~]# systemctl status nginx
	● nginx.service - The nginx HTTP and reverse proxy server
	   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	   Active: active (running) since Sat 2023-04-08 15:56:18 UTC; 8s ago
	  Process: 26433 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	  Process: 26430 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	  Process: 26428 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	 Main PID: 26434 (nginx)
	    Tasks: 3 (limit: 24912)
	   Memory: 5.2M
	   CGroup: /system.slice/nginx.service
		   ├─26434 nginx: master process /usr/sbin/nginx
		   ├─26435 nginx: worker process
		   └─26436 nginx: worker process

	Apr 08 15:56:18 otuslesson.12.selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
	Apr 08 15:56:18 otuslesson.12.selinux nginx[26430]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	Apr 08 15:56:18 otuslesson.12.selinux nginx[26430]: nginx: configuration file /etc/nginx/nginx.conf test is successful
	Apr 08 15:56:18 otuslesson.12.selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
	[root@otuslesson ~]# 
	
	
	Проверим работу утилитой curl:
	
	[root@otuslesson ~]# curl 127.0.0.1:4881
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	    <head>
		<title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
		    /*<\![CDATA[*/
		    body {
			background-color: #fff;
			color: #000;
			font-size: 0.9em;
			font-family: sans-serif,helvetica;
			margin: 0;
			padding: 0;
		    }
		    :link {
			color: #c00;
		    }
		    :visited {
			color: #c00;
		    }


	Первый способ проверили, работает.
	
	<!--############################################################-->
	
	Вторым способом мы разрешим нужный нам порт средствами selinux:
	
	[root@otuslesson ~]# semanage port -l | grep http
	http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
	http_cache_port_t              udp      3130
	http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
	pegasus_https_port_t           tcp      5989
	[root@otuslesson ~]# 
	
	
	Видим разрешенные порты, добавим нужный нам 4881:	
	
	[root@otuslesson ~]# semanage port -a -t http_port_t -p tcp 4881
	[root@otuslesson ~]# semanage port -l | grep http_port_t
	http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988


	Теперь проверим работу:
	
	[root@otuslesson ~]# systemctl restart nginx
	[root@otuslesson ~]# curl 127.0.0.1:4881
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	    <head>
		<title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
		    /*<\![CDATA[*/
		    body {
			background-color: #fff;
			color: #000;
			font-size: 0.9em;
			font-family: sans-serif,helvetica;
			margin: 0;


	Ура! У нас снова все работает.
	
	
	<!--############################################################-->
	
	
	третий способ, это воспользоваться утилитой audit2allow:
	
	[root@otuslesson ~]# pwd
	/root
	[root@otuslesson ~]# ll
	total 16
	-rw-------. 1 root root 5207 Dec  4  2020 anaconda-ks.cfg
	-rw-------. 1 root root 5006 Dec  4  2020 original-ks.cfg
	[root@otuslesson ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
	******************** IMPORTANT ***********************
	To make this policy package active, execute:

	semodule -i nginx.pp

	[root@otuslesson ~]# ll
	total 24
	-rw-------. 1 root root 5207 Dec  4  2020 anaconda-ks.cfg
	-rw-r--r--. 1 root root  960 Apr  8 16:04 nginx.pp
	-rw-r--r--. 1 root root  257 Apr  8 16:04 nginx.te
	-rw-------. 1 root root 5006 Dec  4  2020 original-ks.cfg
	[root@otuslesson ~]# semodule -i nginx.pp
	[root@otuslesson ~]# 
	[root@otuslesson ~]# systemctl restart nginx
	[root@otuslesson ~]# curl 127.0.0.1:4881
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	    <head>
		<title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
		    /*<\![CDATA[*/
		    body {
			background-color: #fff;
			color: #000;
			font-size: 0.9em;
			font-family: sans-serif,helvetica;
			margin: 0;
			padding: 0;

	Ура, у нас получилось воспользоваться тремя способами.
	
</details>
<details>
	<summary>
		Приступим ко второй части домашнего задания:
	</summary>
	
	Развернем стенд для работы и проверим что все поднялось
	
	ashtrey@otuslearn:~/less_12_selinux/otus-linux-adm/selinux_dns_problems$ vagrant status
	Current machine states:

	ns01                      running (virtualbox)
	client                    running (virtualbox)

	This environment represents multiple VMs. The VMs are all listed
	above with their current state. For more information about a specific
	VM, run `vagrant status NAME`.
	
	
	И того видим что две ВМ поднялись и работают.
	
	Подключючаемся к client и пробуем обновить зону:
	
	[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
	> server 192.168.50.10
	> zone ddns.lab 
	> update add www.ddns.lab. 60 A 192.168.50.15
	> send
	update failed: SERVFAIL
	> quit
	
	Видим ошибку. Проверим логи
	
	[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
	type=AVC msg=audit(1681037396.611:2070): avc:  denied  { create } for  pid=5192 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

		Was caused by:
			Missing type enforcement (TE) allow rule.

			You can use audit2allow to generate a loadable module to allow this access.

	[root@ns01 ~]# 


	В логах видим, что политикой безопасности нам запрещен доступ, т.к. указан не верный домен. Проверим так ли это
	
	[root@ns01 ~]# ls -laZ /etc/named
	drw-rwx---. root named system_u:object_r:etc_t:s0       .
	drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
	drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
	-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
	-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
	-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
	-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
	[root@ns01 ~]# 
	
	Да действительно, указан домен etc_t, а какой же верный? Проверим что нам скажет контекст:
	
	[root@ns01 ~]# sudo semanage fcontext -l | grep named
	/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
	/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 

	Контекст подсказывает, что верный домен это named_zone_t. Так что же нам делать?
		- Первое и как мне кажется не самое верное, это воспользоваться подсказкой из лога, а именно создать исключение для нащего случая, воспользовавшись утилитой audit2allow.
		- Изменить домен на верный из контекста, это мне кажется более верный способ, т.к. это предусмотрено политикой безопасности, им и воспользуемся:
		
	Воспользоваться restorecon не можем, т.к. в контексте нет ни чего про /etc/named
		
	[root@ns01 ~]# sudo semanage fcontext -l | grep /etc/named
	/etc/named\.rfc1912.zones                          regular file       system_u:object_r:named_conf_t:s0 
	/var/named/chroot/etc/named\.rfc1912.zones         regular file       system_u:object_r:named_conf_t:s0 
	/etc/named\.conf                                   regular file       system_u:object_r:named_conf_t:s0 
	/etc/named\.root\.hints                            regular file       system_u:object_r:named_conf_t:s0 
	/var/named/chroot/etc/named\.conf                  regular file       system_u:object_r:named_conf_t:s0 
	/etc/named\.caching-nameserver\.conf               regular file       system_u:object_r:named_conf_t:s0 
	/var/named/chroot/etc/named\.root\.hints           regular file       system_u:object_r:named_conf_t:s0 
	/var/named/chroot/etc/named\.caching-nameserver\.conf regular file       system_u:object_r:named_conf_t:s0 
	
	есть только за отдельные файлы, следовательно можен внести изменение в контекст или заменить домен на каталоге:
	
	[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named
	[root@ns01 ~]# ls -laZ /etc/named
	drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
	drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
	drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
	-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
	-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
	-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
	-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
	
	
	Теперь проверим помогло ли нам это? Вернемся на клиента:
	
	[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
	> server 192.168.50.10
	> zone ddns.lab
	> update add www.ddns.lab. 60 A 192.168.50.15
	> send
	> quit
	[vagrant@client ~]$ 
	
	Ошибку не получили
	
	Проверим утилитой dig что она нам вернет за DNS запись
	
	[vagrant@client ~]$ dig www.ddns.lab

	; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.13 <<>> www.ddns.lab
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 65361
	;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

	;; OPT PSEUDOSECTION:
	; EDNS: version: 0, flags:; udp: 4096
	;; QUESTION SECTION:
	;www.ddns.lab.			IN	A

	;; ANSWER SECTION:
	www.ddns.lab.		60	IN	A	192.168.50.15

	;; AUTHORITY SECTION:
	ddns.lab.		3600	IN	NS	ns01.dns.lab.

	;; ADDITIONAL SECTION:
	ns01.dns.lab.		3600	IN	A	192.168.50.10

	;; Query time: 1 msec
	;; SERVER: 192.168.50.10#53(192.168.50.10)
	;; WHEN: Sun Apr 09 13:00:35 UTC 2023
	;; MSG SIZE  rcvd: 96

	[vagrant@client ~]$ 
	
	Видим что добавилась А запись, мы сделали все верно.

</details>




## Linux Administrator _ Lesson #13
	
 Домашнее задание:

	1. Написать Dockerfile на базе apache/nginx который будет содержать две статичные web-страницы на разных портах. Например, 80 и 3000.
	2. Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам localhost:80 и localhost:3000
	3. Добавить 2 вольюма. Один для логов приложения, другой для web-страниц.
	
	Доп.*
	1. Написать Docker-compose для приложения Redmine, с использованием опции build.
	2. Добавить в базовяй образ redmine любую кастомную тему оформления.
	3. Убедиться что после сборки новая тема доступна в настройках.
	
<details>
	<summary>
		Начнем с того, напишем свой Docker файл для запуска nginx
	</summary>
	
	Сам Docerfile:
	
		FROM nginx:latest

		COPY 3000.conf /etc/nginx/conf.d/

		COPY index.html /usr/share/nginx/html/

		COPY index_3000.html /usr/share/nginx_3000/html/index.html

		VOLUME /usr/share/nginx/html

		VOLUME /etc/nginx
		
	Индексные файлы смотреть не интересно, а вот на конфиг взглянем:
	
		server {
		    listen       3000;
		    listen  [::]:3000;
		    server_name  localhost;

		    #access_log  /var/log/nginx/host.access.log  main;

		    location / {
			root   /usr/share/nginx_3000/html;
			index  index.html index.htm;
		    }

		    #error_page  404              /404.html;

		    # redirect server error pages to the static page /50x.html
		    #
		    error_page   500 502 503 504  /50x.html;
		    location = /50x.html {
			root   /usr/share/nginx_3000/html;
		 }
		 
	Видим что порт прослушивается 3000 и другой путь к фалам виртуального хоста
	
	Сбилдим наш контейнер:
	
		root@otuslearn:/home/ashtrey/less_13_docker# docker build -t nginx-only .
		[+] Building 2.4s (9/9) FINISHED                                                                                                                                                                      
		 => [internal] load build definition from Dockerfile                                                                                                                                             0.5s
		 => => transferring dockerfile: 241B                                                                                                                                                             0.0s
		 => [internal] load .dockerignore                                                                                                                                                                0.3s
		 => => transferring context: 2B                                                                                                                                                                  0.0s
		 => [internal] load metadata for docker.io/library/nginx:latest                                                                                                                                  1.4s
		 => [1/4] FROM docker.io/library/nginx:latest@sha256:63b44e8ddb83d5dd8020327c1f40436e37a6fffd3ef2498a6204df23be6e7e94                                                                            0.0s
		 => [internal] load build context                                                                                                                                                                0.3s
		 => => transferring context: 96B                                                                                                                                                                 0.0s
		 => CACHED [2/4] COPY 3000.conf /etc/nginx/conf.d/                                                                                                                                               0.0s
		 => CACHED [3/4] COPY index.html /usr/share/nginx/html/                                                                                                                                          0.0s
		 => CACHED [4/4] COPY index_3000.html /usr/share/nginx_3000/html/index.html                                                                                                                      0.0s
		 => exporting to image                                                                                                                                                                           0.1s
		 => => exporting layers                                                                                                                                                                          0.0s
		 => => writing image sha256:6d16b2015974f9e42a68e0dfd425c76aab5feae1060022eef99c6bfd8689b8f7                                                                                                     0.1s
		 => => naming to docker.io/library/nginx-only  

	И запустим с пробросом наших портов:
	
		root@otuslearn:/home/ashtrey/less_13_docker# docker run -d -p 80:80 -p 3000:3000 nginx-only
		0c9be4c9002f0a37c80464cdcf3364897a1e280af9723d8b1c7cd39637dbf859
		root@otuslearn:/home/ashtrey/less_13_docker# 

	Да, и посмотрим куда пробросились наши вольюмы:
	
	root@otuslearn:/home/ashtrey/less_13_docker# docker volume ls
		DRIVER    VOLUME NAME
		local     2b00eb18f434ad3c6ab762fa190bf454213eb7d8e532d47e63eb50fcc9736728
		local     02c6e596e12d8118ebd9120bc80ff7d12d96db864cc19d3e584e8cf805116d62
		local     3bcc19ce70e7289629486133cc5a9582bd17ef1bf8abf760baec19966219cdf5
		local     06dc07e24e51b51438a5b3e57b4357d1fe4bea9406db575437960b827864522b
		local     13b3fba9405871deeb21b79e4d2507c8703f70b2ead9d41750d17d9894855a7e
		local     16f7005f5eff3cb3e38aac36464a50278ac99f828a0be72da72116e5d364e0c2
		local     18b1e10c6ef501ee505d4b6019cc847ac91b06b3e6dc1d09b6fd7ef3dd021884
		local     82e52c83778c671fa78b365f9e32ed8a58f1dceb4c7d4a1f30c272b590b07cb3
		local     5422ab9dbf6d22e9627f033d42cbbcfd2b672f3726850878b5c2d6e569a75511
		local     172655ca9e9e908b34b9774f62d30bd0f6266f67e7368ff94a17799434539a48
		local     1250718e5b718a1259393427ffe0e90ebf3391613f8cc04c636bca4331e58aa4
		local     58977306d127700694009c2c9ffa9526c93a3886b6a13cb96695e24ee33554f7
		local     bfd7b70ad39497b5d135414f50e6bcd4ed3ed87d70aa7bfc828f0aa91ad1b691
		local     d3f25fffde5162236d891e219a3ca9ac5812647974181ac091f5b11fa3c6b6a0
		root@otuslearn:/home/ashtrey/less_13_docker# 
		
	Ух как много, а это потому что я не удалял их после предыдущих попыток
	
	Нам нужны только эти:
	
		root@otuslearn:/home/ashtrey/less_13_docker# docker inspect 0c9be4c9002f | grep volume
                "Type": "volume",
                "Source": "/var/lib/docker/volumes/16f7005f5eff3cb3e38aac36464a50278ac99f828a0be72da72116e5d364e0c2/_data",
                "Type": "volume",
                "Source": "/var/lib/docker/volumes/172655ca9e9e908b34b9774f62d30bd0f6266f67e7368ff94a17799434539a48/_data",

	Остальные мы удалим и останутся только:
	
		root@otuslearn:/home/ashtrey/less_13_docker# docker volume ls
		DRIVER    VOLUME NAME
		local     16f7005f5eff3cb3e38aac36464a50278ac99f828a0be72da72116e5d364e0c2
		local     172655ca9e9e908b34b9774f62d30bd0f6266f67e7368ff94a17799434539a48
		root@otuslearn:/home/ashtrey/less_13_docker# 
		
	Осталось проверить доступность по портам:
	
	root@otuslearn:/home/ashtrey/less_13_docker# curl localhost 
		<!DOCTYPE html>
		<html>
		<head>
		<title>Welcome to nginx!</title>
		<style>
		html { color-scheme: light dark; }
		body { width: 35em; margin: 0 auto;
		font-family: Tahoma, Verdana, Arial, sans-serif; }
		</style>
		</head>
		<body>
		<h1>Welcome to nginx!</h1>
		<p>If you see this page, it is work on 80 port. Viva Otus!
		Otus learn on page
		<a href="http://otus.ru/">otus page</a>.</p>

		<p><em>Thank you for using nginx.</em></p>
		</body>
		</html>
		root@otuslearn:/home/ashtrey/less_13_docker# 
		
		
		root@otuslearn:/home/ashtrey/less_13_docker# curl localhost:3000
		<!DOCTYPE html>
		<html>
		<head>
		<title>Welcome to nginx!</title>
		<style>
		html { color-scheme: light dark; }
		body { width: 35em; margin: 0 auto;
		font-family: Tahoma, Verdana, Arial, sans-serif; }
		</style>
		</head>
		<body>
		<h1>Welcome to nginx!</h1>
		<p>If you see this page, it is work on 3000 port. Viva Otus!
		Otus learn on page
		<a href="http://otus.ru/">otus page</a>.</p>

		<p><em>Thank you for using nginx.</em></p>
		</body>
		</html>
		root@otuslearn:/home/ashtrey/less_13_docker# 

	Все прекрасно работает!!!
</details>

<details>
	<summary>
		Задание со звездочкой
	</summary>

	Не знаю на сколько все верно я понял, но я создал yml файл, запустил, уменя собрался redmine и mysql и нормально добавилась тема, пример рабочий можно посмотреть по адресу http://64310572bb14.sn.mynetname.net:3000/   admin/12345678
	Тема называется bleucleir

	Docker-compose.yml

	version: '2.17'
	services:
	  redmine:
	    build: .
	    image: redmine
	    restart: always
	    ports:
	      - "8080:3000"
	    depends_on:
	      - db
	    environment:
	      REDMINE_DB_MYSQL: db
	      REDMINE_DB_PASSWORD: 12345
	      REDMINE_SECRET_KEY_BASE: supersecretkey
	  db:
	    image: mysql:5.7
	    restart: always
	    environment:
	      MYSQL_ROOT_PASSWORD: 12345
	      MYSQL_DATABASE: redmine


	Dockerfile

	FROM redmine
	COPY public/themes/bleuclair public/themes/bleuclair


	В корне директории лежит тема, которая закидывается во время сборки
</details>

## Linux Administrator _ Lesson #14
	
 Домашнее задание:

	1. Настроить дашборд с 4-мя графиками

		- память;
		- процессор;
		- диск;
		- сеть
	
	2. Настроить на одной из систем:
		zabbix (использовать screen (комплексный экран);
		prometheus - grafana.
	
<details>
	<summary>
		Настравивать мониторинг я решил на prometheus - grafana, сборщиком метрик выступил node-explorer
	</summary>

		Для решения данной задачи я установить стек из контейнеров на виртуальной машине, для этого написал docker-compose.yml
	После установки получил работающий Prometheus и Grafana. Но графики не строились, погуглив что не так, выяснил что прометей не собирает логи, я 	подключил таргет node-explorer и все заработало.
		Пример рабочего Прометея по ссылке http://64310572bb14.sn.mynetname.net:3000 
	login:pass - admin:grafana
	Скриншот и файлы прикрепляю
</details>

## Linux Administrator _ Lesson #15
	
 Домашнее задание:

	Описание домашнего задания
	1. В Vagrant разворачиваем 2 виртуальные машины web и log
	2. на web настраиваем nginx
	3. на log настраиваем центральный лог сервер на любой системе на выбор
	journald;
	rsyslog;
	elk.
	4. настраиваем аудит, следящий за изменением конфигов nginx 

	Все критичные логи с web должны собираться и локально и удаленно.
	Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
	Логи аудита должны также уходить на удаленную систему.

	Формат сдачи ДЗ - vagrant + ansible

	Дополнительное задание
	развернуть еще машину с elk
	таким образом настроить 2 центральных лог системы elk и какую либо еще;
	в elk должны уходить только логи нжинкса;
	во вторую систему все остальное.

	Статус "Принято" ставится, если присылаете логи скриншоты без вагранта.

	Задание со звездочкой  выполняется по желанию.

	
<details>
	<summary>
		Основное задание
	</summary>

	Для начала создадим Vagrantfile и запустим дву виртуалные машины

	ashtrey@otuslearn:~/less_15_logs$ vboxmanage list vms
	"less_15_logs_web_1683466979961_51713" {81b849f3-3c01-4019-a3f5-6920e56b1616}
	"less_15_logs_log_1683467073122_93308" {17abea65-efa9-4e47-b205-885bc82fffa4}

	Настроеный аудит работает только при наличии файла в директории /var/log/audit/audit.log, как следствие он собирается локально и транслируется на удаленный сервер.

	Лог на WEB

	[root@web audit]# cat audit.log 
	node=web type=DAEMON_START msg=audit(1683477044.246:4167): op=start ver=2.8.5 format=raw kernel=3.10.0-1127.el7.x86_64 auid=4294967295 pid=1652 uid=0 ses=4294967295 subj=system_u:system_r:auditd_t:s0 res=success
	node=web type=CONFIG_CHANGE msg=audit(1683477044.404:1551): auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 op=remove_rule key="nginx_conf" list=4 res=1
	node=web type=CONFIG_CHANGE msg=audit(1683477044.404:1552): auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 op=remove_rule key="nginx_conf" list=4 res=1
	node=web type=CONFIG_CHANGE msg=audit(1683477044.410:1553): audit_backlog_limit=8192 old=8192 auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 res=1
	node=web type=CONFIG_CHANGE msg=audit(1683477044.410:1554): audit_failure=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 res=1
	node=web type=CONFIG_CHANGE msg=audit(1683477044.410:1555): auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 op=add_rule key="nginx_conf" list=4 res=1
	node=web type=CONFIG_CHANGE msg=audit(1683477044.410:1556): auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 op=add_rule key="nginx_conf" list=4 res=1
	node=web type=SERVICE_START msg=audit(1683477044.412:1557): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
	node=web type=SYSCALL msg=audit(1683477070.665:1558): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=103e110 a2=1a4 a3=7fff6f520f20 items=1 ppid=1108 pid=1679 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=13 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"
	node=web type=CWD msg=audit(1683477070.665:1558):  cwd="/var/log/audit"
	node=web type=PATH msg=audit(1683477070.665:1558): item=0 name="/etc/nginx/nginx.conf" inode=33902441 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
	node=web type=PROCTITLE msg=audit(1683477070.665:1558): proctitle=63686D6F64002D78002F6574632F6E67696E782F6E67696E782E636F6E66
	node=web type=SYSCALL msg=audit(1683477120.040:1559): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=125f0f0 a2=1ed a3=7fff0874d3a0 items=1 ppid=1108 pid=1681 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=13 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"
	node=web type=CWD msg=audit(1683477120.040:1559):  cwd="/var/log/audit"
	node=web type=PATH msg=audit(1683477120.040:1559): item=0 name="/etc/nginx/nginx.conf" inode=33902441 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
	node=web type=PROCTITLE msg=audit(1683477120.040:1559): proctitle=63686D6F64002B78002F6574632F6E67696E782F6E67696E782E636F6E66
	[root@web audit]# 


	Лог на Log

	[root@log web]# cat /var/log/audit/audit.log 
		type=DAEMON_START msg=audit(1683477090.883:5854): op=start ver=2.8.5 format=raw kernel=3.10.0-1127.el7.x86_64 auid=4294967295 pid=22477 uid=0 ses=4294967295 subj=system_u:system_r:auditd_t:s0 res=success
	type=CONFIG_CHANGE msg=audit(1683477091.038:1085): audit_backlog_limit=8192 old=8192 auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 res=1
	type=CONFIG_CHANGE msg=audit(1683477091.038:1086): audit_failure=1 old=1 auid=4294967295 ses=4294967295 subj=system_u:system_r:unconfined_service_t:s0 res=1
	type=SERVICE_START msg=audit(1683477091.038:1087): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=auditd comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
	type=DAEMON_ACCEPT msg=audit(1683477120.045:5855): addr=::ffff:192.168.56.10 port=35300 res=success
	node=web type=SYSCALL msg=audit(1683477120.040:1559): arch=c000003e syscall=268 success=yes exit=0 a0=ffffffffffffff9c a1=125f0f0 a2=1ed a3=7fff0874d3a0 items=1 ppid=1108 pid=1681 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=13 comm="chmod" exe="/usr/bin/chmod" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf"
	node=web type=CWD msg=audit(1683477120.040:1559):  cwd="/var/log/audit"
	node=web type=PATH msg=audit(1683477120.040:1559): item=0 name="/etc/nginx/nginx.conf" inode=33902441 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
	node=web type=PROCTITLE msg=audit(1683477120.040:1559): proctitle=63686D6F64002B78002F6574632F6E67696E782F6E67696E782E636F6E66
	[root@log web]# 

	Логи по NGINX собираются на удаленном сервере

	[root@log web]# ll
	total 8
	-rw-------. 1 root root 1732 May  7 18:06 nginx_access.log
	-rw-------. 1 root root  860 May  7 18:06 nginx_error.log

	В целом система понятна, теперь приступим к дополнительному заданию!

</details>

<details>
	<summary>
		Автоматизировать через Ansible
	</summary>

Во вложениях приложил Vagrantfile и Ansible структуру. При запуске из Вагрант собирается два сервера web и log и дальше через ansible происходит настройка.

Единственное не всегда служба перезагружается через таски... возможно глюк
</details>



## Linux Administrator _ Lesson #16
Архитектура сетей

 Домашнее задание:

   Описание домашнего задания
   Дана схема сети
   - Соединить офисы в сеть согласно схеме и настроить роутинг
   - Все сервера и роутеры должны ходить в инет черз inetRouter
   - Все сервера должны видеть друг друга
   - У всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
	при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс
	Формат сдачи ДЗ - vagrant + ansible
<details>
	<summary>
		Теоретическая часть
	</summary>

	В теоретической части требуется: 
	Найти свободные подсети
	Посчитать количество узлов в каждой подсети, включая свободные
	Указать Broadcast-адрес для каждой подсети
	Проверить, нет ли ошибок при разбиении

Сеть office1
- 192.168.2.0/26      	- dev
- 192.168.2.64/26     	- test servers
- 192.168.2.128/26    	- managers
- 192.168.2.192/26    	- office hardware

Сеть office2
- 192.168.1.0/25      	- dev
- 192.168.1.128/26    	- test servers
- 192.168.1.192/26    	- office hardware

Сеть central
- 192.168.0.0/28     	- directors
- 192.168.0.32/28    	- office hardware
- 192.168.0.64/26    	- wifi

Сеть InetRouter
- 192.168.255.0/30	- InetRouter

192.168.2.0/26 		- dev

	netmask 255.255.255.192 | hosts 62 | network 192.168.2.0 | broadcast 192.168.2.63

192.168.2.64/26     	- test servers

	netmask 255.255.255.192 | hosts 62 | network 192.168.2.64 | broadcast 192.168.2.127

192.168.2.128/26    	- managers

	netmask 255.255.255.192 | hosts 62 | network 192.168.2.128 | broadcast 192.168.2.191

192.168.2.192/26    	- office hardware

	netmask 255.255.255.192 | hosts 62 | network 192.168.2.192 | broadcast 192.168.2.255

##Свободных подсетей нет

192.168.1.0/25      	- dev

	netmask 255.255.255.128 | hosts 126 | network 192.168.1.0 | broadcast 192.168.1.127

192.168.1.128/26    	- test servers

	netmask 255.255.255.192 | hosts 62 | network 192.168.1.128 | broadcast 192.168.1.191

192.168.1.192/26    	- office hardware

	netmask 255.255.255.192 | hosts 62 | network 192.168.1.192 | broadcast 192.168.1.255

##Свободных подсетей нет

192.168.0.0/28     	- directors

	netmask 255.255.255.240 | hosts 14 | network 192.168.0.0 | broadcast 192.168.0.15

## Свободная подсеть 192.168.0.16/28

	netmask 255.255.255.240 | hosts 14 | network 192.168.0.16 | broadcast 192.168.0.31

192.168.0.32/28    	- office hardware

	netmask 255.255.255.240 | hosts 14 | network 192.168.0.32 | broadcast 192.168.0.47

## Свободная подсеть 192.168.0.48/28

	netmask 255.255.255.240 | hosts 14 | network 192.168.0.48 | broadcast 192.168.0.63

192.168.0.64/26    	- wifi

	netmask 255.255.255.192 | hosts 62 | network 192.168.0.64 | broadcast 192.168.0.127

## Свободная подсеть 192.168.0.128/25

	netmask 255.255.255.128 | hosts 126 | network 192.168.0.128 | broadcast 192.168.0.255

192.168.255.0/30	- InetRouter

	netmask 255.255.255.252 | hosts 2 | network 192.168.255.0 | broadcast 192.168.255.3

## Свободная подсеть 192.168.255.4/30

	netmask 255.255.255.252 | hosts 2 | network 192.168.255.4 | broadcast 192.168.255.7

## Свободная подсеть 192.168.255.8/29

	netmask 255.255.255.248 | hosts 6 | network 192.168.255.8 | broadcast 192.168.255.15

## Свободная подсеть 192.168.255.16/28

	netmask 255.255.255.240 | hosts 14 | network 192.168.255.16 | broadcast 192.168.255.31

## Свободная подсеть 192.168.255.32/27

	netmask 255.255.255.224 | hosts 30 | network 192.168.255.32 | broadcast 192.168.255.63

## Свободная подсеть 192.168.255.64/26

	netmask 255.255.255.192 | hosts 62 | network 192.168.255.64 | broadcast 192.168.255.127

## Свободная подсеть 192.168.255.128/25

	netmask 255.255.255.128 | hosts 126 | network 192.168.255.128 | broadcast 192.168.255.254

Как мы можем заметить последней подсети в методичке как свободно не описано.

</details>

<details>
	<summary>
		Vagrantfile, разворачиваем стенд
	</summary>

	По методичке создал Vagrantfile, но вот не завелось. Проблема в том, что с сервера не может выкачать box. Ругается на отсуствие прав, что очень странно. Выходом стало внесение изменение, а именно добавил локальные пути до box'ов, которые я предварительно скачал сам. Ключем стала строка:
	box.vm.box_url = "/home/ashtrey/less_16_networks/ubuntu_bullseye64.box"
Теперь у меня есть 7 виртуальных машин и еще один опыт в решении проблем)
</details>

Далее я расскажу как происходила настройка стенда. Дело не сразу заладилось, мне удалось настроить стенд с 3го раза, причем снося все под ноль. Вся соль была в разношорстных ОСях. Лучше всего поддавался настроке CentOS, далее Ubuntu и как ни странно меньше всего мне понравился Debian.

Для того чтобы проверять правильно ли ходят пакет по маршрутам, я сначала установил на все виртуальные машины утилиту traceroute.
yum install traceroute
apt install traceroute

И так начнем с первого сервера и это inetRouter.
Я пользовался утилитами ip a, чтобы посмотреть настройки сетевых интерфейсов, ip r чтобы видеть настроенные маршруты, а также iptables -L -v -n -t nat --line-numbers чтобы видеть настройки iptables.


	Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
	num   pkts bytes target     prot opt in     out     source               destination         
	1     3162  235K MASQUERADE  all  --  *      eth0    0.0.0.0/0           !192.168.0.0/16  



Это самая главная настройка, так остальные сервера и ПК в сети смогут получить доступ к сети интернет через NAT.

Следом по схеме следует сервер CentralRouter, а это значит что нужен обратный маршрут на все подсети которые находятся за ним.
Это можно сделать командой ip route add 192.168.0.0/16 via 192.168.255.2 dev eth1
Другими словами, все одреса назначения из подсети 192.168.0.0 с маской в 16 бит мы должны отправлять на первый интерфейс eth1 и там получателем будет следующий маршрутизатор 192.168.255.2, который точно знает куда деть пришедший пакет.
В качестве проверки проверим наличие интернета, как идет пакет в сеть и доступен ли 192.168.255.2:

	[root@inetRouter ~]# ping ya.ru
	PING ya.ru (77.88.55.242) 56(84) bytes of data.
	64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=63 time=11.9 ms
	64 bytes from ya.ru (77.88.55.242): icmp_seq=2 ttl=63 time=11.5 ms
	64 bytes from ya.ru (77.88.55.242): icmp_seq=3 ttl=63 time=11.7 ms
	64 bytes from ya.ru (77.88.55.242): icmp_seq=4 ttl=63 time=11.5 ms
	64 bytes from ya.ru (77.88.55.242): icmp_seq=5 ttl=63 time=11.4 ms
	^C
	--- ya.ru ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4016ms
	rtt min/avg/max/mdev = 11.468/11.647/11.962/0.209 ms
	[root@inetRouter ~]# traceroute ya.ru
	traceroute to ya.ru (5.255.255.242), 30 hops max, 60 byte packets
	 1  gateway (10.0.2.2)  0.224 ms  0.168 ms  0.223 ms
	 2  * * *
	 3  78.25.155.105 (78.25.155.105)  2.002 ms  1.953 ms  1.900 ms
	 4  78.25.155.75 (78.25.155.75)  2.085 ms  2.037 ms  2.146 ms
	 5  178.18.225.147.ix.dataix.eu (178.18.225.147)  4.971 ms  4.644 ms  4.899 ms
	 6  * vla-32z3-ae2.yndx.net (93.158.172.23)  11.141 ms vla-32z1-ae4.yndx.net (93.158.160.113)  18.926 ms
	 7  * * *
	 8  * * *
	 9  ya.ru (5.255.255.242)  8.260 ms * *
	[root@inetRouter ~]# ping 192.168.255.2
	PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
	64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.360 ms
	64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=1.05 ms
	^C
	--- 192.168.255.2 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1001ms
	rtt min/avg/max/mdev = 0.360/0.707/1.054/0.347 ms
	[root@inetRouter ~]# traceroute 192.168.255.2
	traceroute to 192.168.255.2 (192.168.255.2), 30 hops max, 60 byte packets
	 1  192.168.255.2 (192.168.255.2)  0.573 ms  0.416 ms  0.246 ms
	[root@inetRouter ~]# 


Нужно закрепить этот маршрут.

	[root@inetRouter ~]# cat /etc/sysconfig/network-scripts/route-eth1
	192.168.0.0/16 via 192.168.255.2 dev eth1
	[root@inetRouter ~]# 

Теперь после перезапуска не будет пропадать наш обратный маршрут.

##### CentralRouter #####

Необходимо изменить маршрут по-умолчанию и настроить обратные маршруты

	[vagrant@centralRouter ~]$ ip r
	default via 192.168.255.1 dev eth1 proto static metric 101 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
	192.168.0.0/28 dev eth2 proto kernel scope link src 192.168.0.1 metric 102 
	192.168.0.32/28 dev eth3 proto kernel scope link src 192.168.0.33 metric 107 
	192.168.0.64/26 dev eth4 proto kernel scope link src 192.168.0.65 metric 106 
	192.168.1.0/24 via 192.168.255.6 dev eth6 
	192.168.2.0/24 via 192.168.255.10 dev eth5 
	192.168.56.0/24 dev eth7 proto kernel scope link src 192.168.56.11 metric 104 
	192.168.255.0/30 dev eth1 proto kernel scope link src 192.168.255.2 metric 101 
	192.168.255.4/30 dev eth6 proto kernel scope link src 192.168.255.5 metric 105 
	192.168.255.8/30 dev eth5 proto kernel scope link src 192.168.255.9 metric 103 

default маршрут будет отправлять все пакеты в интерфейс eth1 на адрес 192.168.255.1, он же inetRouter,
а также два обратных маршрута 192.168.1.0/24 via 192.168.255.6 dev eth6 и 192.168.2.0/24 via 192.168.255.10 dev eth5 , это две подсети, которые находятся за office1Router и office2Router. Марштутизатор о них ни чего не знает, он может общаться без маршрутов только с оборудование, которое находится с его интерфейсами в одной подсети, такие как centralServer, он в одной подсети 192.168.0.0/28.
Проверим как работает интернет и как видны все хосты вокруг

	[vagrant@centralRouter ~]$ ping ya.ru
	PING ya.ru (77.88.55.242) 56(84) bytes of data.
	64 bytes from ya.ru (77.88.55.242): icmp_seq=1 ttl=61 time=11.8 ms
	^C
	--- ya.ru ping statistics ---
	1 packets transmitted, 1 received, 0% packet loss, time 0ms
	rtt min/avg/max/mdev = 11.820/11.820/11.820/0.000 ms
	[vagrant@centralRouter ~]$ traceroute ya.ru
	traceroute to ya.ru (5.255.255.242), 30 hops max, 60 byte packets
	 1  gateway (192.168.255.1)  0.416 ms  0.368 ms  0.339 ms
	 2  * * *
	 3  * * *
	 4  78.25.155.105 (78.25.155.105)  1.937 ms  1.916 ms  1.895 ms
	 5  78.25.155.75 (78.25.155.75)  2.190 ms  2.132 ms  2.111 ms
	 6  178.18.225.147.ix.dataix.eu (178.18.225.147)  5.419 ms  5.063 ms  5.016 ms
	 7  * * *
	 8  ya.ru (5.255.255.242)  8.358 ms * *
	[vagrant@centralRouter ~]$ ping 192.168.255.1
	PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
	64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=0.995 ms
	^C
	--- 192.168.255.1 ping statistics ---
	1 packets transmitted, 1 received, 0% packet loss, time 0ms
	rtt min/avg/max/mdev = 0.995/0.995/0.995/0.000 ms
	[vagrant@centralRouter ~]$ ping 192.168.0.2
	PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
	64 bytes from 192.168.0.2: icmp_seq=1 ttl=64 time=0.331 ms
	^C
	--- 192.168.0.2 ping statistics ---
	1 packets transmitted, 1 received, 0% packet loss, time 0ms
	rtt min/avg/max/mdev = 0.331/0.331/0.331/0.000 ms
	[vagrant@centralRouter ~]$ ping 192.168.2.130
	PING 192.168.2.130 (192.168.2.130) 56(84) bytes of data.
	64 bytes from 192.168.2.130: icmp_seq=1 ttl=63 time=1.95 ms
	64 bytes from 192.168.2.130: icmp_seq=2 ttl=63 time=2.12 ms
	^C
	--- 192.168.2.130 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1001ms
	rtt min/avg/max/mdev = 1.954/2.039/2.125/0.096 ms
	[vagrant@centralRouter ~]$ ping 192.168.1.2
	PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
	64 bytes from 192.168.1.2: icmp_seq=1 ttl=63 time=0.640 ms
	64 bytes from 192.168.1.2: icmp_seq=2 ttl=63 time=2.03 ms
	^C
	--- 192.168.1.2 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1000ms
	rtt min/avg/max/mdev = 0.640/1.336/2.033/0.697 ms
	[vagrant@centralRouter ~]$ traceroute 192.168.2.130
	traceroute to 192.168.2.130 (192.168.2.130), 30 hops max, 60 byte packets
	 1  192.168.255.10 (192.168.255.10)  0.974 ms  0.852 ms  0.516 ms
	 2  192.168.2.130 (192.168.2.130)  1.439 ms  2.140 ms  2.047 ms
	[vagrant@centralRouter ~]$ traceroute 192.168.1.2
	traceroute to 192.168.1.2 (192.168.1.2), 30 hops max, 60 byte packets
	 1  192.168.255.6 (192.168.255.6)  0.726 ms  0.601 ms  0.302 ms
	 2  192.168.1.2 (192.168.1.2)  0.644 ms  0.619 ms  0.664 ms
	[vagrant@centralRouter ~]$ 

И так, видно что в интернет ходит, ходит через inetRouter, видит близ лежащие сервера, а так же роутеры за их пределами. Для сохранности так же создаем соответствующие записи в /etc/sysconfig/network-scripts/

И самое главно без чего не смогут бегать пакеты через данные роутер, так разрешение на транзит этих пакетов.

	[vagrant@centralRouter ~]$ cat /proc/sys/net/ipv4/ip_forward
	1
	[vagrant@centralRouter ~]$ cat /etc/sysc
	sysconfig/   sysctl.conf  sysctl.d/    
	[vagrant@centralRouter ~]$ cat /etc/sysctl.conf 
	# sysctl settings are defined through files in
	# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
	#
	# Vendors settings live in /usr/lib/sysctl.d/.
	# To override a whole file, create a new file with the same in
	# /etc/sysctl.d/ and put new settings there. To override
	# only specific settings, add a file with a lexically later
	# name in /etc/sysctl.d/ and put new settings there.
	#
	# For more information, see sysctl.conf(5) and sysctl.d(5).
	net.ipv4.ip_forward = 1
	[vagrant@centralRouter ~]$ 

Для этого в ядро внесл правку и зафиксировали в конфиге, чтобы после перезапуска роутер об этом не забыл.

##### centralServer #####

	[vagrant@centralServer ~]$ ip r
	default via 192.168.0.1 dev eth1 
	default via 10.0.2.2 dev eth0 proto dhcp metric 100 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
	192.168.0.0/28 dev eth1 proto kernel scope link src 192.168.0.2 metric 101 
	192.168.56.0/24 dev eth4 proto kernel scope link src 192.168.56.12 metric 104

Тут нам потредовался только маршрут по-умолчанию

	[vagrant@centralServer ~]$ traceroute ya.ru
	traceroute to ya.ru (77.88.55.242), 30 hops max, 60 byte packets
	 1  gateway (192.168.0.1)  0.954 ms  0.815 ms  0.563 ms
	 2  192.168.255.1 (192.168.255.1)  1.689 ms  2.890 ms  2.810 ms
	 3  * * *
	 4  * * *
	 5  * * *
	 6  78.25.155.75 (78.25.155.75)  34.091 ms  6.061 ms  5.928 ms
	 7  178.18.225.147.ix.dataix.eu (178.18.225.147)  7.419 ms  7.294 ms  7.033 ms
	 8  sas-32z1-ae2.yndx.net (87.250.239.179)  13.877 ms * sas-32z1-ae1.yndx.net (87.250.239.177)  14.434 ms
	 9  * * *
	10  * ya.ru (77.88.55.242)  14.514 ms *

Видим, что пакет побежал по нашему маршруту.

##### office1Router office2Router #####

Настраивались одинаково, это разрешить ходить пакетам через роутер и настроить маршруты по умолчанию.

дальше листинг

	vagrant@office1Router:~$ ping 1.1.1.1
	PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
	64 bytes from 1.1.1.1: icmp_seq=1 ttl=59 time=5.32 ms
	^C
	--- 1.1.1.1 ping statistics ---
	1 packets transmitted, 1 received, 0% packet loss, time 0ms
	rtt min/avg/max/mdev = 5.317/5.317/5.317/0.000 ms
	vagrant@office1Router:~$ traceroute 1.1.1.1
	traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
	 1  _gateway (192.168.255.9)  1.726 ms  1.549 ms  1.329 ms
	 2  192.168.255.1 (192.168.255.1)  2.177 ms  2.117 ms  2.296 ms
	 3  * * *
	 4  * * *
	 5  * * *
	 6  78.25.155.75 (78.25.155.75)  2.725 ms  4.446 ms  4.339 ms
	 7  mskn08.klm22.transtelecom.net (217.150.52.114)  10.224 ms  10.004 ms  9.921 ms
	 8  Cloudflare-msk-gw.transtelecom.net (188.43.3.65)  37.237 ms * *
	 9  * * *
	10  * * *
	11  * * *
	12  * * *
	13  * * one.one.one.one (1.1.1.1)  6.974 ms
	vagrant@office1Router:~$ ip r
	default via 192.168.255.9 dev enp0s8 proto static 
	default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
	10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 
	10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100 
	192.168.2.0/26 dev enp0s9 proto kernel scope link src 192.168.2.1 
	192.168.2.64/26 dev enp0s10 proto kernel scope link src 192.168.2.65 
	192.168.2.128/26 dev enp0s16 proto kernel scope link src 192.168.2.129 
	192.168.2.192/26 dev enp0s17 proto kernel scope link src 192.168.2.193 
	192.168.56.0/24 dev enp0s19 proto kernel scope link src 192.168.56.20 
	192.168.255.8/30 dev enp0s8 proto kernel scope link src 192.168.255.10 
	vagrant@office1Router:~$ cat /etc/netplan/50-vagrant.yaml 
	---
	network:
	  version: 2
	  renderer: networkd
	  ethernets:
	    enp0s8:
	      addresses:
	      - 192.168.255.10/30
	      routes:
	      - to: 0.0.0.0/0
		via: 192.168.255.9
	    enp0s9:
	      addresses:
	      - 192.168.2.1/26
	    enp0s10:
	      addresses:
	      - 192.168.2.65/26
	    enp0s16:
	      addresses:
	      - 192.168.2.129/26
	    enp0s17:
	      addresses:
	      - 192.168.2.193/26
	    enp0s19:
	      addresses:
	      - 192.168.56.20/24
	vagrant@office1Router:~$ 

Т.к. это Ubuntu, то настраивать маршрут пришлось через netplan. После внесения сответствующей записи в yaml файл, необходимо запустить 

	root@office1Router:~# netplan apply
	root@office1Router:~# netplan try
	Do you want to keep these settings?


	Press ENTER before the timeout to accept the new configuration


	Changes will revert in 119 seconds
	Configuration accepted.
	root@office1Router:~# 

Что приятно, утилита пробует ваши настройки и если вы не потеряли связь с сервером и вас устроил результат, нажимаете enter иначе через 120 сек настройки отменятся, что гарантирует от потери связи с устройством.

И листинг со второго сервера

	[vagrant@office2Router ~]$ ip r
	default via 192.168.255.5 dev eth1 proto static metric 104 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
	192.168.1.0/25 dev eth2 proto kernel scope link src 192.168.1.1 metric 103 
	192.168.1.128/26 dev eth3 proto kernel scope link src 192.168.1.129 metric 105 
	192.168.1.192/26 dev eth4 proto kernel scope link src 192.168.1.193 metric 101 
	192.168.56.0/24 dev eth5 proto kernel scope link src 192.168.56.30 metric 102 
	192.168.255.4/30 dev eth1 proto kernel scope link src 192.168.255.6 metric 104 
	[vagrant@office2Router ~]$ cat /etc/sysc
	sysconfig/   sysctl.conf  sysctl.d/    
	[vagrant@office2Router ~]$ cat /etc/sysctl.conf 
	# sysctl settings are defined through files in
	# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
	#
	# Vendors settings live in /usr/lib/sysctl.d/.
	# To override a whole file, create a new file with the same in
	# /etc/sysctl.d/ and put new settings there. To override
	# only specific settings, add a file with a lexically later
	# name in /etc/sysctl.d/ and put new settings there.
	#
	# For more information, see sysctl.conf(5) and sysctl.d(5).
	net.ipv4.ip_forward = 1
	[vagrant@office2Router ~]$ ping 1.1.1.1
	PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
	64 bytes from 1.1.1.1: icmp_seq=1 ttl=59 time=4.87 ms
	64 bytes from 1.1.1.1: icmp_seq=2 ttl=59 time=6.78 ms
	^C
	--- 1.1.1.1 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1005ms
	rtt min/avg/max/mdev = 4.873/5.830/6.788/0.960 ms
	[vagrant@office2Router ~]$ traceroute 1.1.1.1
	traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
	 1  gateway (192.168.255.5)  0.342 ms  0.313 ms  0.290 ms
	 2  192.168.255.1 (192.168.255.1)  0.445 ms  0.426 ms  0.408 ms
	 3  * * *
	 4  * * *
	 5  * * *
	 6  78.25.155.75 (78.25.155.75)  2.503 ms  3.329 ms  3.199 ms
	 7  mskn08.klm22.transtelecom.net (217.150.52.114)  5.718 ms  13.794 ms  13.742 ms
	 8  * * *
	 9  * * *
	10  * one.one.one.one (1.1.1.1)  6.393 ms  6.249 ms
	[vagrant@office2Router ~]$ 
	[vagrant@office2Router ~]$ cat /etc/sysctl.conf 
	# sysctl settings are defined through files in
	# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
	#
	# Vendors settings live in /usr/lib/sysctl.d/.
	# To override a whole file, create a new file with the same in
	# /etc/sysctl.d/ and put new settings there. To override
	# only specific settings, add a file with a lexically later
	# name in /etc/sysctl.d/ and put new settings there.
	#
	# For more information, see sysctl.conf(5) and sysctl.d(5).
	net.ipv4.ip_forward = 1
	[vagrant@office2Router ~]$ cat /etc/sys
	sysconfig/          sysctl.conf         sysctl.d/           systemd/            system-release      system-release-cpe  
	[vagrant@office2Router ~]$ cat /etc/sysconfig/
	anaconda          console/          grub              kernel            network-scripts/  rpcbind           samba             
	authconfig        cpupower          init              man-db            nfs               rpc-rquotad       selinux           
	cbq/              crond             ip6tables-config  modules/          qemu-ga           rsyncd            sshd              
	chronyd           ebtables-config   iptables-config   netconsole        rdisc             rsyslog           wpa_supplicant    
	cloud-info        firewalld         irqbalance        network           readonly-root     run-parts         
	[vagrant@office2Router ~]$ cat /etc/sysconfig/network
	# Created by anaconda
	GATEWAY=192.168.255.5
	GATEWAYDEV=eth1
	[vagrant@office2Router ~]$ cat /etc/sysconfig/network-scripts/
	ifcfg-eth0              ifdown                  ifdown-ppp              ifup-aliases            ifup-plusb              ifup-tunnel
	ifcfg-eth1              ifdown-bnep             ifdown-routes           ifup-bnep               ifup-post               ifup-wireless
	ifcfg-eth2              ifdown-eth              ifdown-sit              ifup-eth                ifup-ppp                init.ipv6-global
	ifcfg-eth3              ifdown-ippp             ifdown-Team             ifup-ippp               ifup-routes             network-functions
	ifcfg-eth4              ifdown-ipv6             ifdown-TeamPort         ifup-ipv6               ifup-sit                network-functions-ipv6
	ifcfg-eth5              ifdown-isdn             ifdown-tunnel           ifup-isdn               ifup-Team               route-eth1
	ifcfg-lo                ifdown-post             ifup                    ifup-plip               ifup-TeamPort           
	[vagrant@office2Router ~]$ cat /etc/sysconfig/network-scripts/route-eth1 
	0.0.0.0/0 via 192.168.255.5
	[vagrant@office2Router ~]$ 

Здесь я столкнулся с проблемой что автоматом поднимался маршрут по умолчанию через сеть виртуальной машины и файл который мы создали для указания своего маршрута ни как нам не помогал после перезапуска системы. Едиственное что помогло это указание шлюза в файле /etc/sysconfig/network

##### office1Server office2Server #####

Тут еще проще, только def маршруты указать и все

	vagrant@office1Server:~$ ip r
	default via 192.168.2.129 dev enp0s8 proto static 
	default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100 
	10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 
	10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100 
	192.168.2.128/26 dev enp0s8 proto kernel scope link src 192.168.2.130 
	192.168.56.0/24 dev enp0s19 proto kernel scope link src 192.168.56.21 
	vagrant@office1Server:~$ cat /etc/netplan/50-vagrant.yaml 
	---
	network:
	  version: 2
	  renderer: networkd
	  ethernets:
	    enp0s8:
	      addresses:
	      - 192.168.2.130/26
	      routes:
	      - to: 0.0.0.0/0
		via: 192.168.2.129
	    enp0s19:
	      addresses:
	      - 192.168.56.21/24
	vagrant@office1Server:~$ ping 1.1.1.1
	PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
	64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=8.25 ms
	64 bytes from 1.1.1.1: icmp_seq=2 ttl=57 time=7.47 ms
	^C
	--- 1.1.1.1 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1002ms
	rtt min/avg/max/mdev = 7.472/7.859/8.246/0.387 ms
	vagrant@office1Server:~$ traceroute 1.1.1.1
	traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
	 1  _gateway (192.168.2.129)  1.231 ms  1.128 ms  1.390 ms
	 2  192.168.255.9 (192.168.255.9)  2.276 ms  2.341 ms  2.120 ms
	 3  192.168.255.1 (192.168.255.1)  2.062 ms  1.923 ms  1.845 ms
	 4  * * *
	 5  * * *
	 6  * * *
	 7  * * *
	 8  mskn08.klm22.transtelecom.net (217.150.52.114)  7.537 ms  7.500 ms  7.460 ms
	 9  Cloudflare-msk-gw.transtelecom.net (188.43.3.65)  7.341 ms  9.078 ms  10.255 ms
	10  one.one.one.one (1.1.1.1)  7.578 ms  9.505 ms  9.112 ms
	vagrant@office1Server:~$ ping 192.168.0.2
	PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
	64 bytes from 192.168.0.2: icmp_seq=1 ttl=62 time=1.19 ms
	64 bytes from 192.168.0.2: icmp_seq=2 ttl=62 time=2.79 ms
	^C
	--- 192.168.0.2 ping statistics ---
	2 packets transmitted, 2 received, 0% packet loss, time 1011ms
	rtt min/avg/max/mdev = 1.186/1.990/2.794/0.804 ms
	vagrant@office1Server:~$ traceroute 192.168.1.2
	traceroute to 192.168.1.2 (192.168.1.2), 30 hops max, 60 byte packets
	 1  _gateway (192.168.2.129)  1.026 ms  0.924 ms  0.864 ms
	 2  192.168.255.9 (192.168.255.9)  2.055 ms  1.972 ms  1.902 ms
	 3  192.168.255.6 (192.168.255.6)  1.845 ms  1.878 ms  1.887 ms
	 4  192.168.1.2 (192.168.1.2)  2.415 ms  2.352 ms  2.295 ms
	vagrant@office1Server:~$ 

Интернет работает, пакеты бегают везде.

И листинг со второго сервера, он на Debian

	vagrant@office2Server:~$ cat /etc/network/interfaces
	# interfaces(5) file used by ifup(8) and ifdown(8)
	# Include files from /etc/network/interfaces.d:
	source-directory /etc/network/interfaces.d

	# The loopback network interface
	auto lo
	iface lo inet loopback

	# The primary network interface
	allow-hotplug eth0
	iface eth0 inet dhcp
	#VAGRANT-BEGIN
	# The contents below are automatically generated by Vagrant. Do not modify.
	auto eth1
	iface eth1 inet static
	      address 192.168.1.2
	      netmask 255.255.255.128
	up ip route add 0.0.0.0/0 via 192.168.1.1
	#VAGRANT-END

	#VAGRANT-BEGIN
	# The contents below are automatically generated by Vagrant. Do not modify.
	auto eth2
	iface eth2 inet static
	      address 192.168.56.31
	      netmask 255.255.255.0
	#VAGRANT-END
	vagrant@office2Server:~$ ip r
	default via 192.168.1.1 dev eth1 
	10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
	192.168.1.0/25 dev eth1 proto kernel scope link src 192.168.1.2 
	192.168.56.0/24 dev eth2 proto kernel scope link src 192.168.56.31 
	vagrant@office2Server:~$ ping 1.1.1.1
	PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
	64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=5.30 ms
	^C
	--- 1.1.1.1 ping statistics ---
	1 packets transmitted, 1 received, 0% packet loss, time 0ms
	rtt min/avg/max/mdev = 5.300/5.300/5.300/0.000 ms
	vagrant@office2Server:~$ traceroute 1.1.1.1
	traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
	 1  192.168.1.1 (192.168.1.1)  0.981 ms  0.875 ms  0.551 ms
	 2  192.168.255.5 (192.168.255.5)  1.215 ms  1.142 ms  1.127 ms
	 3  192.168.255.1 (192.168.255.1)  1.752 ms  1.544 ms  1.475 ms
	 4  * * *
	 5  * * *
	 6  * * *
	 7  * * *
	 8  mskn08.klm22.transtelecom.net (217.150.52.114)  6.696 ms  6.590 ms  6.549 ms
	 9  * Cloudflare-msk-gw.transtelecom.net (188.43.3.65)  7.460 ms  7.403 ms
	10  * one.one.one.one (1.1.1.1)  6.785 ms  6.709 ms
	vagrant@office2Server:~$ traceroute 192.168.0.2
	traceroute to 192.168.0.2 (192.168.0.2), 30 hops max, 60 byte packets
	 1  192.168.1.1 (192.168.1.1)  0.937 ms  0.811 ms  1.087 ms
	 2  192.168.255.5 (192.168.255.5)  1.708 ms  1.871 ms  1.368 ms
	 3  192.168.0.2 (192.168.0.2)  3.854 ms  4.337 ms  4.242 ms
	vagrant@office2Server:~$ traceroute 192.168.2.130
	traceroute to 192.168.2.130 (192.168.2.130), 30 hops max, 60 byte packets
	 1  192.168.1.1 (192.168.1.1)  1.168 ms  1.058 ms  0.989 ms
	 2  192.168.255.5 (192.168.255.5)  1.472 ms  0.816 ms  0.734 ms
	 3  192.168.255.10 (192.168.255.10)  1.104 ms  1.035 ms  0.825 ms
	 4  192.168.2.130 (192.168.2.130)  1.308 ms  1.364 ms  1.392 ms
	vagrant@office2Server:~$ 


Немного отличается настройка, но так же работает интернет и бегают пакеты между серверами и роутерами.

Я специально уперся и настроил весь этот зоопарк, т.к. каждая ОСь имеет особенность. Но настраивать через Ansible выше моих сил, это реально, но придется потратить еще кучу времени.


## Linux Administrator _ Lesson #17
	
 Домашнее задание:

	Настройка PXE сервера для автоматической установки

	1. Следуя шагам из документа https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install  установить и настроить загрузку по сети для дистрибутива CentOS 8.
	В качестве шаблона воспользуйтесь репозиторием https://github.com/nixuser/virtlab/tree/main/centos_pxe 
	2. Поменять установку из репозитория NFS на установку из репозитория HTTP.
	3. Настроить автоматическую установку для созданного kickstart файла (*) Файл загружается по HTTP.
	* 4.  автоматизировать процесс установки Cobbler cледуя шагам из документа https://cobbler.github.io/quickstart/. 
	Задание со звездочкой выполняется по желанию.

	Формат сдачи ДЗ - vagrant + ansible



## Linux Administrator _ Lesson #18

Домашнее задание:

	Научиться создавать пользователей и добавлять им ограничения

	Описание домашнего задания
	1) Запретить всем пользователям, кроме группы admin, логин в выходные (суббота и воскресенье), без учета праздников

	* дать конкретному пользователю права работать с докером
	и возможность рестартить докер сервис

<details>
	<summary>
		Модифицированный Vagrantfile
	</summary>

	# Описание параметров ВМ
	MACHINES = {
	  # Имя DV "pam"
	  :"pam" => {
		      # VM box
		      :box_name => "centos/stream8",
		      #box_version
		      :box_version => "20210210.0",
		      # Количество ядер CPU
		      :cpus => 2,
		      # Указываем количество ОЗУ (В Мегабайтах)
		      :memory => 1024,
		      # Указываем IP-адрес для ВМ
		      :ip => "192.168.56.18",
		    }
	}

	Vagrant.configure("2") do |config|
	  MACHINES.each do |boxname, boxconfig|
	    # Отключаем сетевую папку
	    config.vm.synced_folder ".", "/vagrant", disabled: true
	    # Добавляем сетевой интерфейс
	    config.vm.network "private_network", ip: boxconfig[:ip]
	    # Применяем параметры, указанные выше
	    config.vm.define boxname do |box|
	      box.vm.box = boxconfig[:box_name]
	      #box.vm.box_version = boxconfig[:box_version]
	      box.vm.host_name = boxname.to_s
	      box.vm.box_url = "/home/ashtrey/less_18_pam/centos8.box"
	      box.vm.provider "virtualbox" do |v|
		v.memory = boxconfig[:memory]
		v.cpus = boxconfig[:cpus]
	      end

	      box.vm.provision "shell", inline: <<-SHELL
		  #cp login.sh ~/home
		  #Разрешаем подключение пользователей по SSH с использованием пароля
		  mkdir -p ~root/.ssh
		  cp ~vagrant/.ssh/auth* ~root/.ssh
		  #sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		  sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config
		  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
		  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
		  #Перезапуск службы SSHD
		  systemctl restart sshd.service
		  yum install epel-release -y
		  yum install pam_script -y
		  useradd otusadm 
		  useradd otus
		  echo "Otus2022!" | passwd otusadm --stdin
		  echo "Otus2022!" | passwd otus --stdin
		  groupadd -f admin
		  usermod otusadm -a -G admin
		  usermod root -a -G admin 
		  usermod vagrant -a -G admin
		  systemctl restart sshd
	      SHELL
	      box.vm.provision "file", source: "./login.sh", destination: "/tmp/login.sh"
	      box.vm.provision "shell", inline: "cp /tmp/login.sh /usr/local/bin/"
	    end
	  end
	end

</details>

Его особенность только в том, что почти все уже готово для работы.

В файле /etc/pam.d/sshd вношу изменение

	account    required	pam_exec.so	/usr/local/bin/login.sh

	[vagrant@pam ~]$ ssh otusadm@192.168.56.18
	The authenticity of host '192.168.56.18 (192.168.56.18)' can't be established.
	ECDSA key fingerprint is SHA256:+shcF6B0IPjsEH8sGLNampc2Krmpg8yrN6sQmA4I7rE.
	Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
	Warning: Permanently added '192.168.56.18' (ECDSA) to the list of known hosts.
	otusadm@192.168.56.18's password: 
	[otusadm@pam ~]$ exit
	logout
	Connection to 192.168.56.18 closed.
	[vagrant@pam ~]$ ssh otus@192.168.56.18
	otus@192.168.56.18's password: 
	/usr/local/bin/login.sh failed: exit code 1
	Connection closed by 192.168.56.18 port 22
	[vagrant@pam ~]$ 
			
<details>
	<summary>
		login.sh
	</summary>
	
		ashtrey@otuslearn:~/less_18_pam$ cat login.sh 
		#!/bin/bash
		#Первое условие: если день недели суббота или воскресенье
		if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
		 #Второе условие: входит ли пользователь в группу admin
		 if getent group admin | grep -qw "$PAM_USER"; then
			#Если пользователь входит в группу admin, то он может подключиться
			exit 0
		      else
			#Иначе ошибка (не сможет подключиться)
			exit 1
		    fi
		  #Если день не выходной, то подключиться может любой пользователь
		  else
		    exit 0
		fi
</details>

## Linux Administrator _ Lesson #19

Домашнее задание:

	1.  Реализовать knocking port
	   - centralRouter может попасть на ssh inetrRouter через knock скрипт. 
			Пример в материалах.
	2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) 
			с хоста или форвардится порт через локалхост.
	3. Запустить nginx на centralServer.
	4. Пробросить 80й порт на inetRouter2 8080.
	5. Дефолт в инет оставить через inetRouter.
	Формат сдачи ДЗ - vagrant + ansible
	* реализовать проход на 80й порт без маскарадинга
	

1. Реализовать knocking port

	За основу я взял настроенный стенд из 16 урока по сетям. У нас есть два сервера один inetRouter, а другой centralRouter.
	Проверим что они друг друга видят и мы можем залогиниться на один из них.
	
		[vagrant@centralRouter ~]$ ping 192.168.56.10
		PING 192.168.56.10 (192.168.56.10) 56(84) bytes of data.
		64 bytes from 192.168.56.10: icmp_seq=1 ttl=64 time=0.383 ms
		64 bytes from 192.168.56.10: icmp_seq=2 ttl=64 time=1.22 ms
		^C
		--- 192.168.56.10 ping statistics ---
		2 packets transmitted, 2 received, 0% packet loss, time 999ms
		rtt min/avg/max/mdev = 0.383/0.803/1.224/0.421 ms

		[vagrant@centralRouter ~]$ ssh root@192.168.56.10
		root@192.168.56.10's password: 
		[root@inetRouter ~]# 
		[root@inetRouter ~]# exit
		logout
		Connection to 192.168.56.10 closed.

	
<details>
	<summary>
		На стороне centralRouter
	</summary>
	
Делаем попытку подключиться по ssh

	 [root@centralRouter ~]# ssh root@192.168.255.1
	^C
	
Потерпели неудачу

	[root@centralRouter ~]# nmap -Pn --host-timeout 100 --max-retries 1 -p 8881 192.168.255.1
	
	Starting Nmap 6.40 ( http://nmap.org ) at 2023-06-16 15:50 UTC
	Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
	Nmap scan report for 192.168.255.1
	Host is up (0.00041s latency).
	PORT     STATE    SERVICE
	8881/tcp filtered unknown
	MAC Address: 08:00:27:8D:67:90 (Cadmus Computer Systems)
	
	Nmap done: 1 IP address (1 host up) scanned in 0.48 seconds
	
	[root@centralRouter ~]# nmap -Pn --host-timeout 100 --max-retries 1 -p 7777 192.168.255.1
	
	Starting Nmap 6.40 ( http://nmap.org ) at 2023-06-16 15:50 UTC
	Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
	Nmap scan report for 192.168.255.1
	Host is up (0.00037s latency).
	PORT     STATE    SERVICE
	7777/tcp filtered cbt
	MAC Address: 08:00:27:8D:67:90 (Cadmus Computer Systems)
	
	Nmap done: 1 IP address (1 host up) scanned in 0.45 seconds
	
	[root@centralRouter ~]# nmap -Pn --host-timeout 100 --max-retries 1 -p 9991 192.168.255.1
	
	Starting Nmap 6.40 ( http://nmap.org ) at 2023-06-16 15:51 UTC
	Nmap scan report for 192.168.255.1
	Host is up (0.00052s latency).
	PORT     STATE  SERVICE
	9991/tcp closed issa
	MAC Address: 08:00:27:8D:67:90 (Cadmus Computer Systems)
	
	Nmap done: 1 IP address (1 host up) scanned in 0.55 seconds

 Делаем еще попытку подключиться
 
	[root@centralRouter ~]# ssh root@192.168.255.1
	The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
	ECDSA key fingerprint is SHA256:88V8PIkB6SJL10DApPycuJR1sbN3nhYhhv/ClsxWHqw.
	ECDSA key fingerprint is MD5:3a:a9:99:72:c8:52:04:ce:d8:8e:14:1a:62:01:d7:5e.
	Are you sure you want to continue connecting (yes/no)? yes
	Warning: Permanently added '192.168.255.1' (ECDSA) to the list of known hosts.
	Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
	[root@centralRouter ~]# 

 Все получилось, только нас не пустило. А не пустила настройка 
	[root@centralRouter ~]#      
	[root@centralRouter ~]# vi /etc/ssh/sshd_config 

 	Меняем PasswordAuthentication no
  	на PasswordAuthentication yes
   
	И все!!!
</details>

<details>
	<summary>
 		Доступность inetRouter2(192.168.0.2) через хост
   	</summary>

	ashtrey@otuslearn:~/less_19_iptables$ ping 192.168.0.2
	PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
	64 bytes from 192.168.0.2: icmp_seq=88 ttl=62 time=2.45 ms
	64 bytes from 192.168.0.2: icmp_seq=89 ttl=62 time=2.42 ms
	64 bytes from 192.168.0.2: icmp_seq=90 ttl=62 time=2.28 ms
	64 bytes from 192.168.0.2: icmp_seq=91 ttl=62 time=2.49 ms
	64 bytes from 192.168.0.2: icmp_seq=92 ttl=62 time=2.53 ms
	64 bytes from 192.168.0.2: icmp_seq=93 ttl=62 time=2.41 ms
	^C
	--- 192.168.0.2 ping statistics ---
	93 packets transmitted, 6 received, 93.5484% packet loss, time 94097ms
	rtt min/avg/max/mdev = 2.282/2.431/2.532/0.078 ms
 
	ashtrey@otuslearn:~/less_19_iptables$ traceroute 192.168.0.2
	traceroute to 192.168.0.2 (192.168.0.2), 30 hops max, 60 byte packets
	 1  192.168.56.10 (192.168.56.10)  0.642 ms  0.589 ms  0.603 ms
	 2  192.168.255.2 (192.168.255.2)  2.550 ms  2.631 ms  2.601 ms
	 3  192.168.0.2 (192.168.0.2)  2.817 ms  2.775 ms  2.727 ms
  
	ashtrey@otuslearn:~/less_19_iptables$ ip r
	192.168.0.0/28 via 192.168.56.10 dev vboxnet0 
	192.168.56.0/24 dev vboxnet0 proto kernel scope link src 192.168.56.1 
	192.168.88.0/24 dev enp1s0 proto kernel scope link src 192.168.88.14 metric 100 
	192.168.88.0/24 dev wlp2s0 proto kernel scope link src 192.168.88.2 metric 600 
	ashtrey@otuslearn:~/less_19_iptables$ 

 Мне пришлось прописать прописать маршруты на машинах, после чего icmp побежал правильным маршрутом
</details>

<details>
	<summary>
		Проброс порта на centralRouter:80
 	</summary>

  Для этого добавил на inetRouter2 пару правил

  	[root@inetRouter2 ~]# iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.1:80
	[root@inetRouter2 ~]# iptables -t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.0.2:8080

И теперь с хоста делая запрос на uinetRouter2:8080
	ashtrey@otuslearn:~$ curl 192.168.0.2:8080
 Нам ответит Nginx с centralRouter

ashtrey@otuslearn:~$ curl 192.168.0.2:8080
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	  <title>Welcome to CentOS</title>
	  <style rel="stylesheet" type="text/css"> 
	
		html {
		background-image:url(img/html-background.png);
		background-color: white;
		font-family: "DejaVu Sans", "Liberation Sans", sans-serif;
		font-size: 0.85em;
		line-height: 1.25em;
		margin: 0 4% 0 4%;
		}

</details>
