#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

# Recorded original payload
#payload 34:08:04:93:53:99 00:19:db:4e:3d:d9 88e1 007ca000b0520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

# Check dependencies
#package="libpcap0.8-dev" ; system "dpkg -l | grep ^ii.*#{package} || aptitude install #{package}"
#package="pcaprub" ; system "gem list | grep #{package} || gem install #{package}"
#package="packetfu" ; system "gem list | grep #{package} || gem install #{package}"

require 'packetfu'

# The first interface available
#this is buggy since "state UP" isn't allways given#interface = `ip address show | grep "state UP" | awk '{print $2}' | cut -d: -f1`.chomp
#interface="enp4s0"
interface="wlp3s0"

frame = PacketFu::EthPacket.new
frame.eth_saddr=`ip address show #{interface} | grep "link/ether" | awk '{print $2}'`.chomp

# HomePlug ethertype
frame.eth_proto=0x88e1

# This payload will restart the homeplug
frame.payload=["007ca000b0520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"].pack('H*')

# Upstairs
frame.eth_daddr="34:08:04:93:53:98"
#frame.eth_daddr="34:08:04:93:53:99" #is it bad?
puts frame.inspect
frame.to_w(interface)
puts
sleep 10
# Downstairs
frame.eth_daddr="34:08:04:93:53:8e"
puts frame.inspect
frame.to_w(interface)
