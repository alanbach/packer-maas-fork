poweroff
eula --agreed
lang en_US.UTF-8
keyboard us
timezone UTC --utc

network --device eth0 --bootproto=dhcp
selinux --enforcing

ignoredisk --only-use=vda
bootloader --disabled
zerombr
clearpart --all --initlabel --drives=vda
part swap --size=2048
part / --fstype=ext4 --grow --size=1

# Anolis OS 23 x86_64 network installation source and update repository.
url ${KS_OS_REPOS} ${KS_PROXY}
repo --name="anolis23-updates" ${KS_UPDATES_REPOS} ${KS_PROXY}

# Lock direct root login. Use the sudo-capable admin account instead.
rootpw --iscrypted --lock '$6$Dl49Z0NTgdGHgXC6$hckqAiDpjhO720FvC8qoXQ8x9cXxXpys5Ecq6W386a9rT9oFQWUipvfS2hZM5D0lAeg9oPdgcRdBzZDL1mb/1.'
user --name=admin --groups=wheel --password='$6$Dl49Z0NTgdGHgXC6$hckqAiDpjhO720FvC8qoXQ8x9cXxXpys5Ecq6W386a9rT9oFQWUipvfS2hZM5D0lAeg9oPdgcRdBzZDL1mb/1.' --iscrypted

%post --erroronfail --log=/root/anaconda-post.log
# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/grub.d/10_linux
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/grub.d/10_linux
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/grub.d/10_linux
sed -i 's/GRUB_ENABLE_BLSCFG=.*/GRUB_ENABLE_BLSCFG=false/g' /etc/grub.d/10_linux

# Fix curtin ID_LIKE
echo 'ID_LIKE="rhel centos fedora"' >> /etc/os-release

# Fix curtin boot loader installation
cp -r /boot/efi/EFI/anolis* /boot/efi/EFI/redhat

sudo tee /etc/cloud/cloud.cfg.d/90-default-user.cfg >/dev/null <<'EOF'
system_info:
  default_user:
    name: admin
    gecos: Admin User
    home: /home/admin
    shell: /bin/bash
    primary_group: admin
    groups:
      - wheel
      - systemd-journal
    sudo:
      - "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: true
EOF

dnf clean all
%end

%packages --nocore --ignoremissing
@core
kernel
openssh-server
sudo
chrony
grubby
dnf
lvm2
bash-completion
cloud-init
# cloud-init only requires python3-oauthlib with MAAS. As such upstream
# removed this dependency.
python3-oauthlib
rsync
tar
# grub2-efi-x64 ships grub signed for UEFI secure boot. If grub2-efi-x64-modules
# is installed grub will be generated on deployment and unsigned which breaks
# UEFI secure boot.
grub2-pc
grub2-efi-*
shim-*
grub2-efi-*-modules
efibootmgr
nano
vi

-kmod-hisdk3
%end
