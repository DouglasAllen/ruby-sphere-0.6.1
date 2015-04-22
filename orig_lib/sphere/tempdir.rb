#
# tempdir: manipulates temporary directories
#
# $Id: tempdir.rb,v 1.4 2005/06/18 00:52:41 tomono Exp $
#
# copied from tempfile.rb,v 1.19 2003/07/23 16:37:35 eban Exp
# in ruby-1.8.1 and edited.
#
# Copyright:: edited part Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::	 GPL
#

require 'delegate'
require 'tmpdir'
require 'fileutils'
require 'sphere/version'

# thread safe.
class TempDir < SimpleDelegator
  MAX_TRY = 10
  TMPDIR = "/var/cache/#{Sphere::NAME}"
  @@cleanlist = []

  # Creates a temporary file of mode 0600 in the temporary directory
  # whose name is basename.pid.n and opens with mode "w+".	A Tempfile
  # object works just like a File object.
  #
  # If tmpdir is omitted, the temporary directory is determined by
  # TempDir::TMPDIR (/var/cache/ruby-sphere), or it is not found,
  # Dir::tmpdir provided by 'tmpdir.rb'.
  # When $SAFE > 0 and the given tmpdir is tainted, it uses
  # /tmp. (Note that ENV values are tainted by default)
  def initialize(basename, tmpdir=nil)
    if $SAFE > 0 and tmpdir.tainted?
      tmpdir = '/tmp'
    elsif not tmpdir
      if File.directory?( TMPDIR )
        tmpdir = TMPDIR
      else
        tmpdir = Dir::tmpdir
      end
    end

    lock = nil
    n = failure = 0

    begin
      tmpname = Dir.mktmpdir(basename, tmpdir)
    rescue NoMethodError	# RUBY_VERSION <= 1.8.6
      begin
        Thread.critical = true

        begin
          tmpname = sprintf('%s/%s%d.%d', tmpdir, basename, $$, n)
          n += 1
        end while @@cleanlist.include?(tmpname) or File.exist?(tmpname)

        Dir.mkdir(tmpname)
      rescue
        failure += 1
        retry if failure < MAX_TRY
        raise "cannot generate tempdir `%s'" % tmpname
      ensure
        Thread.critical = false
      end
    end

    @data = [tmpname]
    @clean_proc = TempDir.callback(@data)
    ObjectSpace.define_finalizer(self, @clean_proc)

    @tmpname = tmpname
    @@cleanlist << @tmpname
    @data[1] = @@cleanlist

    super(@tmpname)

  end

  # Closes and unlinks the file.
  def remove!
    @clean_proc.call
    ObjectSpace.undefine_finalizer(self)
  end

  # Unlinks the file.	On UNIX-like systems, it is often a good idea
  # to unlink a temporary file immediately after creating and opening
  # it, because it leaves other programs zero chance to access the
  # file.
  def unlink
    # keep this order for thread safeness
    FileUtils.rm_r( @tmpname, :force=>true )
    @@cleanlist.delete(@tmpname) if @@cleanlist
  end
  alias delete unlink

  # Returns the full path name of the temporary file.
  def path
    @tmpname
  end

  class << self
    def callback(data)				# :nodoc:
      pid = $$
      lambda{
        if pid == $$ 
          path, tmpfile, cleanlist = *data

          print "removing ", path, "..." if $DEBUG

          # keep this order for thread safeness
          FileUtils.rm_r( path, :force=>true )
          cleanlist.delete(path) if cleanlist

          print "done\n" if $DEBUG
        end
      }
    end
  end

end
