#!/bin/sh
# WRT54G Mesh config script
# Kenneth Finnegan, 2014

HOSTNAME="WRTdefault"
SUBNET="10.44.254"
CHANNEL="11"
ESSID="KWF-mesh"

opkg update
opkg install olsrd ahcpd

cat <<EOF >/etc/config/olsrd
config olsrd
	option config_file '/etc/olsrd.conf'
EOF

cat <<EOF >/etc/olsrd.conf
IpVersion	4

Hna4 {
$SUBNET.0 255.255.255.0
}

Interfaces "wl0" {
Ip4Broadcast 255.255.255.255
AutoDetectChanges yes
}
EOF

cat <<EOF >/etc/config/system
config 'system'
	option 'hostname' '$HOSTNAME'
	option 'zonename' 'America/Los Angeles'
	option 'timezone' 'PST8PDT,M3.2.0,M11.1.0'
	option 'log_ip' '10.44.1.10'
	option 'log_port' '514'
	option 'cronloglevel' '8'
	
config 'timeserver' 'ntp'
	list 'server' '0.openwrt.pool.ntp.org'
	list 'server' '1.openwrt.pool.ntp.org'
	list 'server' '2.openwrt.pool.ntp.org'
	list 'server' '3.openwrt.pool.ntp.org'
	list 'server' '10.44.10.1'
EOF

cat <<EOF >/etc/config/dhcp
config 'dnsmasq'
	option 'domainneeded' '1'
	option 'boguspriv' '1'
	option 'localise_queries' '1'
	option 'local' '/lan/'
	option 'domain' 'lan'
	option 'expandhosts' '1'
	option 'authoritative' '1'
	option 'readethers' '1'
	option 'leasefile' '/tmp/dhcp.leases'
	option 'resolvfile' '/tmp/resolv.conf.auto'
	option 'rebind_protection' '0'

config 'dhcp' 'lan'
	option 'interface' 'lan'
	option 'start' '100'
	option 'limit' '99'
	option 'leasetime' '12h'

config 'dhcp' 'wan'
	option 'interface' 'wan'
	option 'ignore' '1'
EOF


cat <<EOF >/etc/config/network
config 'switch' 'eth0'
	option 'enable' '1'

config 'switch_vlan' 'eth0_0'
	option 'device' 'eth0'
	option 'vlan' '0'
	option 'ports' '0 1 2 3 5'

config 'switch_vlan' 'eth0_1'
	option 'device' 'eth0'
	option 'vlan' '1'
	option 'ports' '4 5'

config 'interface' 'loopback'
	option 'ifname' 'lo'
	option 'proto' 'static'
	option 'ipaddr' '127.0.0.1'
	option 'netmask' '255.0.0.0'

config 'interface' 'lan'
	option 'ifname' 'eth0.0'
	option 'proto' 'static'
	option 'netmask' '255.255.255.0'
	option 'ipaddr' '$SUBNET.1'

config 'interface' 'wan'
	option 'ifname' 'eth0.1'
	option 'proto' 'dhcp'

config 'interface' 'mesh'
	option 'ifname' 'wl0'
	option 'proto' 'ahcp'
EOF

cat <<EOF >/etc/config/wireless
config 'wifi-device' 'wl0'
	option 'type' 'broadcom'
	option 'txpower' '18'
	option 'hwmode' '11bg'
	option 'channel' '$CHANNEL'

config 'wifi-iface'
	option 'device' 'wl0'
	option 'network' 'mesh'
	option 'encryption' 'none'
	option 'mode' 'adhoc'
	option 'ssid' '$ESSID'
EOF

