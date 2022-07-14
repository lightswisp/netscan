#!/usr/bin/ruby
require "socket"
require "timeout"

class PortScanner
	def initialize(range, output)
		@ports_map = {
			80 => "http/80",
			443 => "https/443",
			20 => "ftp/20",
			21 => "ftp/21",
			22 => "ssh/22",
			23 => "telnet/23",
			25 => "smtp/25",
			53 => "dns/53",
			110 => "pop3/110",
			43 => "whois/43",
			3306 => "mysql/3306",
			8080 => "proxy/8080"
			
		}
		@range = range
		@output = output
		@ips = range.size
		@port_threads = []
		@ports_open = {}
		puts "Scanning with -O option!" if @output
	end

	def start()
		start_time = Time.now
		puts "Started at #{start_time}\n"
		@ips.times do |i|
				@ports_map.each_key do |port|
					@port_threads << Thread.new do
						ip = @range[i]
						begin
							if Socket.tcp(ip, port, connect_timeout: 1)
								#puts "#{ip}:#{port} is open!"
								@ports_open[ip] = (@ports_open[ip] || []) << @ports_map[port]
							end
						rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::ENETUNREACH

						end
					end
				end			
		end
			
		@port_threads.each {|pth| pth.join}
		end_time = Time.now
		@ports_open.each {|key, value|
			puts "Scan results for: #{key}"
			puts "PORT" + " "*7 + "STATE"
			value.each { |port|
				puts port + " "*(12-port.size) + "OPEN"
			}
			puts
		}
		puts "Ended for #{end_time-start_time}s"
	end
end
