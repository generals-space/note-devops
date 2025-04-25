nmcli connection modify enp0s5 +ipv4.address 192.168.10.1/24 ipv4.method manual
nmcli connection modify enp0s5 -ipv4.address 192.168.10.2/24
nmcli connection down enp0s5 && nmcli connection up enp0s5
