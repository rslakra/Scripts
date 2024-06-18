#find out shared directories on the specified server
#showmount -e 192.168.2.108

#make the following directory on the local machine.
#mkdir /data
#mkdir /data_temp

#make the following directory on the local machine.
sudo mount -t nfs devfs1.rslakra.net:/vol/data_fs1 /data
sudo mount -t nfs devis1.rslakra.net:/vol/data_is1 /data_temp
