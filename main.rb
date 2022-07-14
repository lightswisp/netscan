#!/usr/bin/ruby
require "ipaddr"
require "./ports.rb"

def main()
	if !ARGV[0]
		puts "\033[91mNo ip address specified! \n\033[1mUsage: ruby main.rb [ip_address_mask] example: ruby main.rb 192.168.2.0/24 -P -O" 
		return
	end

	range, range_list = nil
	# range is an array that stores two ip addresses [0] -> from and [1] -> to
	# range_list is an array that stores all ip addresses starting from range[0] to range[1]  
	threads = [] # array for threads
	range_valid = [] #valid ip adresses 
	mask 	    = ARGV[0]  # ip mask 
	scan_ports  = ARGV.include?("-P")
	output_info = ARGV.include?("-O")
	
	begin
		range = IPAddr.new(mask).to_range.to_s.split("..")
		range_list = IPAddr.new(range[0])..IPAddr.new(range[1])
		range_list = range_list.to_a
		range_list.map!{|ip| ip.to_s}
	rescue IPAddr::InvalidAddressError
		puts "\033[91mInvalid address format! Quitting..."
		return
	end

	range_list.size.times do |i|
		threads	<< Thread.new do
			if system("ping -w 8 -b -c1 #{range_list[i]} > /dev/null") == true
				range_valid.append(range_list[i])
				puts "\033[92m#{range_valid.size}. #{range_list[i]}"
			end
		end
	end

	threads.each {|th| th.join}
	puts "\033[96m#{range_valid.size} devices are alive!"

	if(scan_ports)
		puts "\e[37mScanning ports for #{range_valid.size} ip addreses..."
		p = PortScanner.new(range_valid, output_info)
		p.start()
	end
end

main()
