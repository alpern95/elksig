#! /usr/bin/ruby

# == Synopsis
#
# snmpscan: a simple yet powerful snmp scanner
#
# == Usage
#
# snmpscan [OPTION] ip-range
#
# -h, --help:
#    show help
#
# --timeout x, -t x:
#    timeout x milliseconds (for faster scans), default 1 second
#
# --mib m, -m m:
#    optional mib to use, defaults to sysDescr
#
# --comunity c, -c c
#    comunity string, default "public"
#
# --protocol p, -p p
#    version of the protocolo, defaults to 2c
#
# --version, -v
#    version of the software
#
# --verbose, -V
#    be verbose in output
#
# ip-range: An ip range (in the form 192.168.10.0/24)
# or a single address (172.30.16.1)
#
# == Examples
#
# snmpscan 10.10.10.64
#    Scans host 10.10.10.64 with default values
#
# snmpscan -t 200 -c comread -m sysName 172.30.149.0/24
#    Scans a range of 255 addresses for mib sysName.0, with comunity password "comread"
#    and a timeout value of 200 milliseconds
#
# == Author and license
#    Written by Marco Ceresa
#    Distributed under the same license as Ruby is
#

$VERSION = 0.1

begin
  require 'snmp'
rescue LoadError
  require 'rubygems'
  require_gem 'snmp'
end
require 'ipaddr'
require 'timeout'
require 'getoptlong'
#require 'usage'
require 'thwait'

opts = GetoptLong.new([ '--help', '-h', GetoptLong::NO_ARGUMENT ],
                      [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
                      [ '--verbose', '-V', GetoptLong::NO_ARGUMENT ],
                      [ '--timeout', '-t', GetoptLong::REQUIRED_ARGUMENT ],
                      [ '--mib', '-m', GetoptLong::REQUIRED_ARGUMENT ],
                      [ '--protocol', '-p', GetoptLong::REQUIRED_ARGUMENT ],
                      [ '--comunity', '-c', GetoptLong::REQUIRED_ARGUMENT ]
                      )

# Defaults
timeout = 1000
mib = "sysDescr.0"
protocol = "2c"
comunity = "public"
verbose = false

opts.each do |opt, arg|
  case opt
  when '--help'
    RDoc::usage
  when '--version'
    puts "snmpscan, version #$VERSION"
    exit 0
  when '--timeout'
    timeout = arg.to_i
  when '--mib'
    mib = arg
    unless mib =~ /\.\d+$/
      mib += ".0"
    end
  when '--protocol'
    protocol = arg
  when '--comunity'
    comunity = arg
  when '--verbose'
    verbose = true
  end
end

puts "\nSNMP Scanner v.#$VERSION (c) Marco Ceresa 2006"
puts "Reference at http://snmpscan.rubyforge.org/"
print "Starting scanner for #{ARGV[0]} at #{Time.now}\n\n"

if ARGV.length != 1
  print "\nMissing ip-range argument (try --help)\n\n"
  exit 0
end

args = [timeout,mib,protocol,comunity]
print "Arguments: #{args.join ' '}\n\n" if verbose

class IPAddr
  # The broadcast method calculate the broadcast
  # address of the range (if any)
  def broadcast
    return @addr + (IPAddr::IN4MASK - @mask_addr)
  end
  # The each_address method iterates over each address
  # of the ip range
  def each_address
    (@addr..broadcast).each do |addr|
      yield _to_string(addr)
    end
  end
end

iprange = IPAddr.new(ARGV.shift,Socket::AF_INET)
threads = []
$stdout.sync = true



iprange.each_address do |ip|
  begin
    threads << Thread.new(ip,args) do |ip,args|
      timeout,mib,protocol,comunity = args
      begin
        SNMP::Manager.open(:Host => ip,
                           :Community => comunity,
                           :Port => 161,
                           :Timeout => (timeout/1000.0)) do |man|
          res = man.get([mib])
          answer = res.varbind_list[0].value
          print "#{ip}:\t#{answer}\n"
        end
      rescue
        print "#{ip}:\t#$!\n" if verbose
      end
    end
  rescue
    next
  end
end
