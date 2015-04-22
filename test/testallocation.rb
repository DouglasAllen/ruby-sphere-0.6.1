# testallocation.rb: testcases for allocation.rb
# $Id: testallocation.rb,v 1.5 2004/12/09 01:55:01 tomono Exp $
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

class TestAllocation < Test::Unit::TestCase
  include Sphere

  def test_initialize
    tzbak = ENV['TZ']
    ENV['TZ'] = 'HST'
    t = Allocation.new( \
                       Time.local( 2004, 10, 20, 18, 00, 00 ), \
                       Time.local( 2004, 10, 21, 6, 00, 00 ) \
                      )
    #assert_equal( "2004/10/20(HST)-", t.comment )
    assert_equal( nil, t.comment )
    ENV['TZ'] = 'Japan'
    t = Allocation.new( \
                       Time.local( 2004, 10, 20, 18, 00, 00 ), \
                       Time.local( 2004, 10, 21, 6, 00, 00 ) \
                      )
    assert_equal( nil, t.comment )
    ENV['TZ'] = tzbak
  end

  def test_each_sec
    t = Allocation.new( \
                       Time.local( 2004, 10, 20, 18, 00, 00 ), \
                       Time.local( 2004, 10, 21, 6, 00, 00 ) \
                      )
    i = 0
    t.each_sec( 3600 ) do |c|
      i += 1
    end
    assert_equal( 13, i )
  end

  def test_each_sec_on
    Allocation.new( \
                   Time.local( 2004, 10, 20, 17, 32, 30 ), \
                   Time.local( 2004, 10, 20, 18, 59, 59 ) \
                  ).each_sec_on( 3600 ) do |c|
      assert_equal( Time.local( 2004, 10, 20, 18, 00, 00 ), c )
    end
    target = [
      Time.local( 2004, 10, 19, 23, 0, 0 ),
      Time.local( 2004, 10, 20, 0, 0, 0 ),
      Time.local( 2004, 10, 20, 1, 0, 0 ),
      Time.local( 2004, 10, 20, 2, 0, 0 ),
      Time.local( 2004, 10, 20, 3, 0, 0 ),
      Time.local( 2004, 10, 20, 4, 0, 0 ),
      Time.local( 2004, 10, 20, 5, 0, 0 ),
      Time.local( 2004, 10, 20, 6, 0, 0 ),
    ]
    a = Allocation.new( \
                       Time.local( 2004, 10, 19, 22, 30, 30 ), \
                       Time.local( 2004, 10, 20, 6, 59, 59 ) \
                      )
    2.times do	# strange bug in each_sec_on
      result = Array.new
      a.each_sec_on( 3600 ) do |c|
        result << c
      end
      assert_equal( target, result )
    end
  end

  def test_duration
    t = Allocation.new( \
                       Time.local( 2004, 10, 20, 18, 00, 00 ), \
                       Time.local( 2004, 10, 21, 6, 00, 00 ) \
                      )
    assert_equal( 3600 * 12, t.duration )
  end

  def test_sunrises
    r = Allocation.new(
      Time.utc( 2004, 10, 10, 14, 00, 00 ), \
      Time.utc( 2004, 10, 15, 22, 00, 00 ), \
      Observatory::of( 'Mauna Kea' )
    ).sunrises
    # from http://aa.usno.navy.mil/data/docs/RS_OneDay.html for Hilo
    g = [
      Time.utc( 2004, 10, 10, 16, 14 ),
      Time.utc( 2004, 10, 11, 16, 14 ),
      Time.utc( 2004, 10, 12, 16, 14 ),
      Time.utc( 2004, 10, 13, 16, 15 ),
      Time.utc( 2004, 10, 14, 16, 15 ),
      Time.utc( 2004, 10, 15, 16, 15 ),
    ]
    g.zip( r ) do |goal, result|
      assert_in_delta( goal, result, 120 )
    end
  end

end
