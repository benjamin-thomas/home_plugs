#!/usr/bin/env ruby

require 'bundler'

Bundler.require(:default)
require "logger"
#require "colored"


def display_uptime_message(minutes_counter, resets_counter, packet_loss)
  x_minutes = "#{minutes_counter} minute"
  x_minutes += "s" unless minutes_counter == 1

  hours = minutes_counter / 60
  x_hours = "#{hours}h"
  #x_hours += "s" unless hours == 1

  x_resets = "#{resets_counter} reset"
  x_resets += "s" unless resets_counter == 1
  puts "HomePlugs uptime: #{x_minutes.green} [#{x_hours.blue}] (#{x_resets.yellow} so far) [latest packet_loss = #{packet_loss.red}]"
end

#log = Logger.new("/var/log/keep_homeplugs_alive.log", "daily")
log = Logger.new(STDOUT)
log.info "Process start: #{Time.now}"

minutes_counter = 0
resets_counter = 0
while true
  # Send 100 packets every 0.1s == probing for 10 seconds
  # packet_loss = `sudo ping -i0.1 -w10 192.168.0.254 | tail -n2 | head -n1 | awk '{print $6}'`.chomp

  # Send 300 packets every 0.1s == probing for 30 seconds
  packet_loss = `sudo ping -i0.1 -w30 192.168.1.100 | tail -n2 | head -n1 | awk '{print $6}'`.chomp

  # if packet_loss == "100%"
  # Trying to reset if not 0%
  if packet_loss != "0%"
    log_msg = "Resetting home plugs (packet_loss was _#{packet_loss}_)"

    log.debug <<-EOF

    #{("#" * log_msg.size).green}
    #{log_msg.red}
    #{("#" * log_msg.size).green}
    EOF

    # This should be symlinked to /usr/local/sbin and handled with the sudoers file NOPASSWD
    system "sudo ./reset_homeplugs.rb"
    sleep 30 # Leave more time for the home plugs to reset fully
    minutes_counter = 0
    resets_counter += 1
  else
    display_uptime_message(minutes_counter, resets_counter, packet_loss)
    sleep 30 # Don't ping probe constantly. One dot = 1 minute ok
    minutes_counter += 1
  end
  # sleep 0.1 #this is so I can control-C out of it
end
