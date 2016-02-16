#! C:/Ruby22/bin/ruby.exe
#
# visibility: CLI to plot visiblity maps
#
# $Id: visibility,v 1.3 2006/07/21 12:30:13 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

# ruby-sphere library
require 'sphere'

# command line options
require 'optparse'
parser = OptionParser.new
opts = Hash.new
parser.banner = "#{File.basename( $0 )}: plots a visibility map.\nusage: #{File.basename( $0 )} [options]"
parser.on( '-h', '--help', 'prints help' ) {
	puts parser.help
	exit 0
}
parser.on( '-v', '--version', 'prints version' ) {
	puts "#{File.basename( $0 )} in #{Sphere::PKGNAME}"
	exit 0
}
parser.on( '-V', 'prints version and copyright notice' ) {
	puts "#{File.basename( $0 )} in #{Sphere::PKGNAME}\n\n"
	puts Sphere::COPYRIGHT_LONG
	exit 0
}
parser.on( '-c', '--config FILE', "reads configuration from FILE in addition to #{Sphere::Conf::FILES.join(', ')}" ) { |v|
	if File.readable?( File.expand_path( v ) ) then
		opts[:c] = Array.new unless opts[:c]
		opts[:c] << v
	else
		raise OptionParser::ParseError, "#{v}: file not found"
	end
}

begin
	parser.parse!
rescue OptionParser::ParseError => err
	$stderr.puts err.message
	$stderr.puts parser.help
	exit 1
end

# setup configuration
plot = Sphere::Conf::read( opts[:c] || [] )
begin
	plot.plot
	errors = plot.errors
	unless errors.empty?
		$stderr.puts "Warning:"
		$stderr.puts errors.join( "\n" )
	end
rescue Sphere::ConfError => err
	$stderr.puts "Error:"
	$stderr.puts err.message
	exit 1
end
