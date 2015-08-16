#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'snmp'
begin
peer=ARGV.first
fichier=(peer)
directory="/tmp/"
now = DateTime.now
mois = now.month
annee = now.year
jour= now.day

ENT_PHYSICAL_INDEX = '1.3.6.1.2.1.47.1.1.1.1.1'
ENT_PHYSICAL_DESC = '1.3.6.1.2.1.47.1.1.1.1.2'
ENT_PHYSICAL_SERIAL_NUMBER = '1.3.6.1.2.1.47.1.1.1.1.11'
ENT_PHYSICAL_MODEL_NAME = '1.3.6.1.2.1.47.1.1.1.1.13'

columns = [ ENT_PHYSICAL_DESC, ENT_PHYSICAL_SERIAL_NUMBER]
abort "give hostname as argument and community." if ARGV.empty?

serials = Array.new
$ligne = "ent_physical_desc,ent_physical_serial_number\n"

SNMP::Manager.open(:Host => ARGV.first, :Community => ARGV[1]) do |mgr|
  mgr.walk(columns) do |row|
    unless serials.include?(row[0].value.to_s) || row[1].value.to_s.downcase == 
'unknown'
      if row[1].value.to_s == ""
       else
        $ligne << "#{row[0].value.to_s},#{row[1].value.to_s}""\n"
      end
      serials << row[0].value.to_s
    end
  end
end
if $ligne
  SortieFile = File.new(directory+fichier+"_"+jour.to_s+"-"+mois.to_s+"-"+annee.
to_s+".log", "w")
  SortieFile.puts($ligne)
  SortieFile.close
  else
  retCode=2
  retCodeLabel="Erreur d'inventaire"
  puts "#{retCodeLabel}"
  exit retCode
end
puts("Inventaire ok, le "+jour.to_s+"-"+mois.to_s+"-"+annee.to_s)
rescue
  puts "Erreur dans le programe ou probleme de connexion"
ensure
  puts("All is done")
end
