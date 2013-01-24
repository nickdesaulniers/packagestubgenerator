#!/usr/bin/ruby
require 'FileUtils'

# Monkeypatch String to add helper methods
class String
  def green
    colorize 32
  end
  def red
    colorize 31
  end
  private
  def colorize color_code
    "\e[#{color_code}m#{self}\e[0m"
  end
end

# Get info from user
puts 'Please provide the following information about your packaged app stub'
print 'App name: '
app_name = gets
print '128x128px Icon path: '
icon_path = gets
print 'Future location of package.manifest: '
future_manifest_location = gets
puts "\nI will now create a package app stub for"
puts app_name
puts 'using the icon from'
puts icon_path
puts 'which will look for future updates from'
puts "#{future_manifest_location}\n"

# minor validation
#unless icon_path =~ /.+\.png/
#  puts 'please provide a png for the icon'.red
#  exit false
#end

#unless File.file? icon_path
#  puts 'please provide a valid path to your 128x128px file path'.red
#  exit false
#end

# check for zip
puts 'checking for zip'
zip_installed = `which zip`.rstrip

if zip_installed.length == 0
  puts 'please install zip or make it accessible to your path'.red
  exit false
end
puts "zip installed: #{zip_installed}".green

# Make a temp dir that will end up getting zipped
puts 'making a temporary working directory: ./tmp'
if File.directory? './tmp'
  puts 'please rm -rf tmp/'.red
  exit false
end
Dir.mkdir './tmp'

# create index.html
puts 'generating tmp/index.html'
File.open 'tmp/install.html', 'w' do |f|
  f << <<-HEREDOC
<html>
  <body>
    <p>Packaged app installation page</p>
    <script>
      var manifestUrl = '/package.manifest';
      var req = navigator.mozApps.installPackage(manifestUrl);
      req.onsuccess = function() {
        alert(this.result.origin);
      };
      req.onerror = function() {
        alert(this.error.name);
      };
    </script>
  </body>
</html>
  HEREDOC
end

# TODO
# create other files...
# zip up files...

# clean up ./tmp
FileUtils.rm_rf './tmp'
