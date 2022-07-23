# Scripting for setting prerequisites configuration on CentOS 7 Only
# Execute using sudo Permissions

# Install bin-utils
sudo yum install bind-utils -y

# Disable the system swappiness
echo 'Disabling swappiness..'
sudo sysctl vm.swappiness=1
sudo echo 'vm.swappiness=1' >> /etc/sysctl.conf
sudo echo 'net.ipv6.conf.all.disable_ipv6=1' >> /etc/sysctl.conf
sudo echo 'net.ipv6.conf.default.disable_ipv6=1' >> /etc/sysctl.conf
sudo sysctl -p
sudo sed -i 's/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo 'Done.'

# Disable Transparent hugepages(THP)
echo 'Disabling THP'
sudo echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local
sudo echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local
echo 'Done'

# ADD Grub Options
echo 'adding grub options..'
OLD_GRUB=$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX | cut -d '"' -f 2)
NEW_GRUB=$(echo "$OLD_GRUB transparent_hugepage=never ipv6.disable=1")
sudo sed -i "s+$OLD_GRUB+$NEW_GRUB+g" /etc/default/grub
sleep 2
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
echo 'Done.'

# Set enforce 0
echo 'set enforce..'
sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config
echo 'Done.'

# Start chronyd
sudo systemctl start chronyd

#If chronyd is not installed, install ntp or chronyd.
#sudo yum install ntp -y
#sudo service ntpd start
#sudo chkconfig ntpd on


# Disable IPtables
echo 'Disabling IP tables..'
sudo iptables -F
sudo systemctl stop iptables
sudo systemctl disable iptables
sudo systemctl stop firewalld
sudo systemctl disable firewalld
echo 'Done.'

# Disable "tuned" service
echo 'Disabling TuneD service..'
sudo systemctl stop tuned
sudo systemctl disable tuned 
echo 'Done'

# Install nscd service:
echo 'Installing nscd..'
sudo yum install nscd -y
sudo service nscd start
sudo chkconfig nscd on
echo 'Done.'

