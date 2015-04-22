# from http://pub.cozmixng.org/~hiki/programming/?(Test%3A%3AUnit)%A5%C1%A5%E5%A1%BC%A5%C8%A5%EA%A5%A2%A5%EB

require 'test/unit'

$:.unshift(File.join(File.expand_path(".")))
$:.unshift(File.join(File.expand_path(".."), "lib"))
$:.unshift(File.join(File.expand_path(".."), "test"))

# For ruby-1.9
require 'stringio'
class StringIO
  def path
    nil
  end
end

test_file = "test/test*.rb"

Dir.glob(test_file) do |file|
  require file.sub(/\.rb$/, '')
end
