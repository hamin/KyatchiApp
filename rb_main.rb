#
# rb_main.rb
# KyatchiApp
#
# Created by Haris Amin on 6/13/11.
# Copyright __MyCompanyName__ 2011. All rights reserved.
#

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  require(path) unless path == main
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
