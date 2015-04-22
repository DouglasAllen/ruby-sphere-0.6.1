# testconf.rb: testcases for conf.rb
# $Id: testconf.rb,v 1.20 2007/02/05 01:12:44 tomono Exp $
#
# Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
#
# Permission is granted for use, copying, modification, distribution, and
# distribution of modified versions of this work under the terms of GPL
# version 2 or later.
#

require 'test/unit'
$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

require 'stringio'
#~ class StringIO
  #~ def path
    #~ nil
  #~ end
#~ end

class TestConfItem < Test::Unit::TestCase
  include Sphere

  def test_new
    t = ConfItem.new( 'key', 'val', 'path', 1 )
    assert_equal( 'key', t.key )
    assert_equal( 'val', t.val )
    assert_equal( 'path', t.path )
    assert_equal( 1, t.line )
  end

  def test_readline
    t = ConfItem.readline( 'key value #comment' )
    assert_equal( 'key', t.key )
    assert_equal( 'value', t.val )
    t = ConfItem.readline( ' #only comment' )
    assert_equal( nil, t )
    t = ConfItem.readline( 'key #only key' )
    assert_equal( 'key', t.key )
    assert_equal( nil, t.val )
  end

end

class TestConf < Test::Unit::TestCase
  require 'stringio'
  include Sphere

  def _remove_dir( dir )
    if FileTest.directory?( dir ) then
      Dir.open( dir ).each do |f|
        next if '.' == f or '..' == f
        File.unlink( File.join( dir, f ) )
      end
      Dir.unlink( dir )
    end
  end

  def test_read
    Conf::read
  end

  #~ def test_conf
    #~ input = StringIO.new("# comment\nlocation Mauna Loa	# to be overridden\n
		                      #~ location Mauna Kea\nlon 1\nlat 2")

    #~ t = Conf.new.readconf( input )
    #~ assert_equal( [ 'Mauna Loa', 'Mauna Kea' ], t['location'].map{ |c| c.val} )
    #~ assert_equal( [ '1' ], t['lon'].map{ |c| c.val} )
    #~ assert_equal( [ '2' ], t['lat'].map{ |c| c.val} )
    #~ assert_equal( [ 'Mauna Loa', 'Mauna Kea' ], t['location'].map{ |c| c.val} )
    #~ t.push( ConfItem.new( 'location', 'Mt. Evelest', 'path', 1 ) )
    #~ assert_equal( [ 'Mauna Loa', 'Mauna Kea', 'Mt. Evelest' ], t['location'].map{ |c| c.val} )
  #~ end

  #~ def test_conf_parse
    #~ clock = Time.utc( 2004, 12, 16, 0, 0, 0 )
    #~ t = Conf::new( clock )
    #~ t.readconf( StringIO.new( "location Mauna Kea\n" ) )
    #~ assert_equal( 'Mauna Kea', t.parsed[ 'location' ] )
    #~ t.readconf( StringIO.new( "location Mauna Loa\n" ) )
    #~ assert_equal( 'Mauna Loa', t.parsed[ 'location' ] )
    #~ t.readconf( StringIO.new( "Sun\n" ) )
    #~ assert_equal( [ ['Sun'] ], t.parsed[ 'Star' ] )
    #~ t.readconf( StringIO.new( "Moon\n" ) )
    #~ assert_equal( [ ['Sun'], ['Moon'] ], t.parsed[ 'Star' ] )
    #~ t.readconf( StringIO.new( "Star +12:34:56 -12:45 test star\n" ) )
    #~ assert_equal( 'test star', t.parsed[ 'Star' ][2][0] )
    #~ assert_in_delta( '+12:34:56'.hms_to_rad, t.parsed[ 'Star' ][2][1], '00:00:01'.hms_to_rad )
    #~ assert_in_delta( '-12:45'.dms_to_rad, t.parsed[ 'Star' ][2][2], '00:00:01'.dms_to_rad )
    #~ t.readconf( StringIO.new( "+23:45:56 +12:45 test star 2\n" ) )
    #~ assert_equal( 'test star 2', t.parsed[ 'Star' ][3][0] )
    #~ assert_in_delta( '+23:45:56'.hms_to_rad, t.parsed[ 'Star' ][3][1], '00:00:01'.hms_to_rad )
    #~ assert_in_delta( '+12:45'.dms_to_rad, t.parsed[ 'Star' ][3][2], '00:00:01'.dms_to_rad )
    #~ t.readconf( StringIO.new( "01:23:45,+67:12 test star 3\n" ) )
    #~ assert_equal( 'test star 3', t.parsed[ 'Star' ][4][0] )
    #~ assert_in_delta( '01:23:45'.hms_to_rad, t.parsed[ 'Star' ][4][1], '00:00:01'.hms_to_rad )
    #~ assert_in_delta( '+67:12'.dms_to_rad, t.parsed[ 'Star' ][4][2], '00:00:01'.dms_to_rad )
    #~ t.readconf( StringIO.new( "Star 01:23:45,+67:12 test star 4\n" ) )
    #~ assert_equal( 'test star 4', t.parsed[ 'Star' ][5][0] )
    #~ assert_in_delta( '01:23:45'.hms_to_rad, t.parsed[ 'Star' ][5][1], '00:00:01'.hms_to_rad )
    #~ assert_in_delta( '+67:12'.dms_to_rad, t.parsed[ 'Star' ][5][2], '00:00:01'.dms_to_rad )
    #~ assert_equal( nil, t.confs[-1].error )
    #~ t.readconf( StringIO.new( "error Mauna Kea\n" ) )
    #~ assert_equal( "'error' is not recognized as a configuration keyword", t.confs[-1].error )
    #~ assert_equal( nil, t.confs[-1].key )
    #~ assert_equal( nil, t.confs[-1].val )
    #~ assert_equal( nil, t.parsed[ 'start' ] )
    #~ s = Time.utc( 2004, 12, 16, 2, 0, 0 )
    #~ t.readconf( StringIO.new( "start #{s}\n" ) )
    #~ assert_equal( s, t.parsed[ 'start' ].time( Observatory.of( 'Mauna Kea' ) ) )
    #~ t.readconf( StringIO.new( "finish sunrise\n" ) )
    #~ assert_equal( :sunrise, t.parsed[ 'finish' ].symbol )
    #~ # t.readconf( StringIO.new( "finish 1010-12-12 15:36:12 HST\n" ) )
    #~ # assert_raise( RuntimeError ){t.parsed['finish'].time}
    #~ # Above is not an error on Ruby 1.8.6p111 and 1.9.1p0
    #~ assert_equal( 1, t.errors.size )
    #~ t.readconf( StringIO.new( "datadir\n" ) )
    #~ t.readconf( StringIO.new( "location\n" ) )
    #~ assert_equal( <<'_END', t.errors_to_s )
#~ 1: 'error' is not recognized as a configuration keyword
#~ 1: 'location' needs an argument
#~ _END
  #~ end

  def test_conf_to_allocation
    tzorig = ENV['TZ']
    ENV['TZ'] = 'HST'
    t = Conf::new( Time.local( 2004, 12, 15, 12, 0, 0 ) )
    t.readconf( StringIO.new( "location Mauna Kea" ) )
    t.readconf( StringIO.new( "start sunset\n" ) )
    t.readconf( StringIO.new( "finish sunrise\n" ) )
    a = t.allocate!
    assert_equal( 'Mauna Kea', a.observatory.comment )
    assert_in_delta( '-155 28'.dms_to_rad, a.observatory.lon, '0 01'.dms_to_rad )
    assert_in_delta( '+19 50'.dms_to_rad, a.observatory.lat, '0 01'.dms_to_rad )
    assert_in_delta( Time.local( 2004, 12, 15, 17, 45, 39 ), a.from, 1 )
    assert_in_delta( Time.local( 2004, 12, 16, 6, 49, 44 ), a.to, 1 )
    ENV['TZ'] = tzorig
  end

  #~ def test_only_location
    #~ input = StringIO.new( <<'_END' )
#~ location Mauna Kea
#~ start 2004-12-15 sunset
#~ finish 2004-12-16 sunrise
#~ _END
    #~ actual = Conf.new.readconf( input ).allocate!.observatory
    #~ expected = Observatory.of('Mauna Kea')
    #~ [:comment, :lon, :lat].each do |ivar|
      #~ assert_equal(expected.send(ivar), actual.send(ivar))
    #~ end
  #~ end

  def test_location_with_lon_lat
    input = StringIO.new( <<'_END' )
location Kanata
lon 132:46:36
lat +34:22:39
start 2004-12-15 sunset
finish 2004-12-16 sunrise
_END
    actual = Conf.new.readconf( input ).allocate!.observatory
    assert_equal('Kanata', actual.comment)
    assert_equal('132:46:36'.dms_to_rad, actual.lon)
    assert_equal('+34:22:39'.dms_to_rad, actual.lat)
  end

  #~ def test_only_lon_lat
    #~ input = StringIO.new( <<'_END' )
#~ lon 132:46:36
#~ lat +34:22:39
#~ start 2004-12-15 sunset
#~ finish 2004-12-16 sunrise
#~ _END
    #~ t = Conf.new.readconf( input )
    #~ actual = t.allocate!.observatory
    #~ assert_equal('132:46:36 +34:22:39', actual.comment)
    #~ assert_equal('132:46:36'.dms_to_rad, actual.lon)
    #~ assert_equal('+34:22:39'.dms_to_rad, actual.lat)
  #~ end

  def test_no_location
    input = StringIO.new( <<'_END' )
start 2004-12-15 sunset
finish 2004-12-16 sunrise
_END
    t = Conf.new.readconf( input )
    assert_raises( Sphere::ConfError ){ t.allocate! }
  end

  def test_conf_to_plot
    t = Conf.new
    t.readconf( StringIO.new( <<'_END' ) )
location Mauna Kea
start 2004-12-15 sunset
finish 2004-12-16 sunrise
Sun
Moon
02:42:40.7 -00:00:48 NGC 1068
_END
    p = t.to_plot
    assert_equal( Sphere::Sun, p.stars[0].class )
    assert_equal( Sphere::Moon, p.stars[1].class )
    assert_equal( Sphere::Star, p.stars[2].class )
    assert_equal( 'NGC 1068', p.stars[2].name )
    assert_in_delta( '02:42:40.7'.hms_to_rad, p.stars[2].ra, '00:00:00.1'.hms_to_rad )
    assert_in_delta( '-00:00:48'.dms_to_rad, p.stars[2].dec, '00:00:01'.dms_to_rad )
    p.plot
  end

  def test_conf_to_conf
    conf = <<'_END'
# observatory
location Mauna Kea

# time span
start 2004-12-15 sunset
finish 2004-12-16 sunrise

# plotting options
plotter GnuPlot
device png
output visibility.png
datadir testconf-dir

# stars
Sun
Moon
02:42:40.7 -00:00:48 NGC 1068	# main target
_END
    t = Conf.new
    t.readconf( StringIO.new( conf ) )
    assert_equal( conf, t.to_conf )
    _remove_dir( 'testconf-dir' )
    t.plot
    assert( FileTest.directory?( 'testconf-dir' ), 'data directory not created' )
    assert( FileTest.file?( 'testconf-dir/Moon.dat' ), 'data file not created' )
    assert( FileTest.file?( 'testconf-dir/NGC 1068.dat' ), 'data file not created' )
    assert( FileTest.file?( 'testconf-dir/Sun.dat' ), 'data file not created' )
    assert( FileTest.file?( 'testconf-dir/visibility.plot' ), 'plot file not created' )
    assert( FileTest.file?( 'testconf-dir/visibility.png' ), 'output image not created' )
    _remove_dir( 'testconf-dir' )
  end

  def test_azelrange
    conf = <<'_END'
		# observatory
    location Mauna Kea

    # time span
    start 2004-12-15 sunset
    finish 2004-12-16 sunrise

    # plotting options
    plotter GnuPlot
    device png
    output visibility.png
    datadir testconf-range-dir
    el-min 45
    el-max 75
    az-center 180
    az-halfwidth 45

    # stars
    00:00:00 +00:00 test star
_END
    t = Conf.new
    t.readconf( StringIO.new( conf ) )
    _remove_dir( 'testconf-range-dir' )
    t.plot
    pngpath='testconf-range-dir/visibility.png'
    assert( FileTest.file?( pngpath ), 'output image not created' )
    puts "\n#{__FILE__}:#{__LINE__} #{pngpath} created. Have a look.\n"
  end

  def test_now
    conf = "start now\n"
    t = Conf.new
    t.readconf( StringIO.new( conf ) )
    c = Time.now
    assert_in_delta( c, t.parsed['start'].time, 1 )
  end

  #~ def test_azel
    #~ # HD220363
    #~ conf = <<'_END'
#~ location Mauna Kea
#~ start 2005-12-13 sunset
#~ finish 2005-12-14 sunrise

#~ 23:23:05 +12:18:50 HD220363
#~ AzEl 164.5542 82.2107 18:04:45
#~ _END
    #~ t = Conf.new
    #~ t.readconf( StringIO.new( conf ) )
    #~ assert_equal( ['Az:164.5542 El:82.2107 at 18:04:45', 164.5542.to_rad, 82.2107.to_rad, '18:04:45'], t.parsed['AzEl'][0] )
    #~ t.azel_to_radec!
    #~ assert_in_delta(t.parsed['Star'][0][1], t.parsed['Star'][-1][1], '00:00:01'.hms_to_rad)
    #~ assert_in_delta(t.parsed['Star'][0][2], t.parsed['Star'][-1][2], '00:00:01'.dms_to_rad)
  #~ end

  def test_hint_evening
    t = Conf.new
    t.readconf( StringIO.new( <<'_END' ) )
start twilight
finish now
location Mauna Kea
_END
    t.allocate!	# Sphere::ConfError raised without correct for to AstroTime
  end

  def test_hint_morning
    t = Conf.new
    t.readconf( StringIO.new( <<'_END' ) )
start now
finish twilight
location Mauna Kea
_END
    t.allocate!	# Sphere::ConfError raised without correct for to AstroTime
  end

  def test_nodir_file_output
    target = 'HD220363.png'
    assert(!File.exist?(target), "Test output file #{target} already exists")
    t = Conf.new
    t.readconf(StringIO.new(<<'_END'))
location Mauna Kea
start 2005-12-13 sunset
finish 2005-12-14 sunrise
device png small
output HD220363.png

23:23:05 +12:18:50 HD220363
_END
    t.plot
    assert(File.exist?(target), "Failed to create test output file #{target}")
    File.unlink(target)
  end

  def test_dir_file_output
    dir = 'test-dir-file-output'
    Dir.mkdir(dir) unless File.directory?(dir)
    target = 'HD220363.png'
    t = Conf.new
    t.readconf(StringIO.new(<<'_END'))
location Mauna Kea
start 2005-12-13 sunset
finish 2005-12-14 sunrise
datadir test-dir-file-output
device png small
output HD220363.png

23:23:05 +12:18:50 HD220363
_END
    t.plot
    ['HD220363.png', 'HD220363.dat', 'visibility.plot'].each do |file|
    path = File.join(dir, file)
    assert(File.exist?(path), "Failed to create test output file #{path}")
    File.unlink(path)
  end
    Dir.unlink(dir)
  end

end

class TestAstroTime < Test::Unit::TestCase
  include Sphere

  #~ def test_explicit
    #~ t = AstroTime.new( 'Thu Jul 20 23:30:05 HST 2006' )
    #~ assert_equal(Time.utc(2006, 7, 21, 9, 30, 5), t.time)
  #~ end

  def test_now
    t = AstroTime.new( 'now' )
    assert_in_delta(Time.now, t.time, 1)
  end

  #~ def test_nextday
    #~ t = AstroTime.new( 'Thu Jul 20 28:30:05 HST 2006' )
    #~ assert_equal(Time.parse( 'Fri Jul 21 04:30:05 HST 2006' ), t.time)
  #~ end

  def test_day_before
    t = AstroTime.new( 'Thu Jul 20 -4:30:05 HST 2006' )
    assert_equal(Time.parse( 'Wed Jul 19 20:30:05 HST 2006' ), t.time)
  end

  def test_sunset
    t = AstroTime.new( '2006-07-20 HST sunset' )
    assert_in_delta(Time.utc(2006, 7, 20, 5, 3, 21), t.time(Observatory.of('Mauna Kea')), 1)
  end

  def test_twilight
    t = AstroTime.new( '2006-07-20 HST twilight', :evening )
    assert_in_delta(Time.utc(2006, 7, 20, 5, 55, 40), t.time(Observatory.of('Mauna Kea')), 1)
  end

  def test_sunrise
    t = AstroTime.new( '2006-07-20 HST sunrise' )
    assert_in_delta(Time.utc(2006, 7, 19, 15, 52, 53), t.time(Observatory.of('Mauna Kea')), 1)
  end

  #~ def test_midnight
    #~ t = AstroTime.new( '2006-07-20 HST midnight' )
    #~ assert_in_delta(Time.utc(2006, 7, 21, 10, 00, 00), t.time(Observatory.of('Mauna Kea')), 1)
  #~ end

  #~ def test_noon
    #~ t = AstroTime.new( '2006-07-20 HST noon' )
    #~ assert_in_delta(Time.utc(2006, 7, 20, 22, 00, 00), t.time(Observatory.of('Mauna Kea')), 1)
  #~ end

  #~ def test_exact_hhmm
    #~ t = AstroTime.new( '2006-07-20 13:24 HST' )
    #~ assert_equal(Time.utc(2006, 7, 20, 23, 24, 00), t.time(Observatory.of('Mauna Kea')))
  #~ end

  #~ def test_exact_hhmmss
    #~ t = AstroTime.new( '2006-07-20 13:24:45 HST' )
    #~ assert_equal(Time.utc(2006, 7, 20, 23, 24, 45), t.time(Observatory.of('Mauna Kea')))
  #~ end

  #~ def test_offset
    #~ t = AstroTime.new( '2006-07-20 25:24:45 HST' )
    #~ assert_equal(Time.utc(2006, 7, 21, 11, 24, 45), t.time(Observatory.of('Mauna Kea')))
    #~ t = AstroTime.new( '2006-07-20 -1:24:45 HST' )
    #~ assert_equal(Time.utc(2006, 7, 20, 9, 24, 45), t.time(Observatory.of('Mauna Kea')))
  #~ end

  def test_notvalid
    t = AstroTime.new( 'moge' )
    assert_raise( RuntimeError ){ t.time }
  end

  def test_with_range_from_now
    t = AstroTime.new( 'now' )
    now = Time.now
    alloc = Allocation.new( now, now + 3600, Observatory.of('Mauna Kea') )
    assert_in_delta(now, t.time(alloc), 1)
  end

  def test_with_range
    t = AstroTime.new( 'now' )
    now = Time.now
    alloc = Allocation.new( now - 3600, now + 3600, Observatory.of('Mauna Kea') )
    assert_in_delta(now, t.time(alloc), 1)
  end

end
