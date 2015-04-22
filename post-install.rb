#
# post-install.rb: executed from setup.rb after installation to
#                  make the cache directory and adjust permissions
#
require 'etc'
nobody = Etc.getpwnam( 'nobody' )

$:.unshift( './lib' )
require 'sphere'

begin
  Dir.mkdir( TempDir::TMPDIR )
rescue Errno::EEXIST
end
File.chown( nobody.uid, nobody.gid, TempDir::TMPDIR )
File.chmod( 01777, TempDir::TMPDIR )
$stderr.puts( "mkdir #{TempDir::TMPDIR}" )
