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
app_name = gets().rstrip
print '128x128px Icon path: '
icon_path = gets().rstrip
print 'Future location of package.manifest: '
future_manifest_location = gets.rstrip()
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
File.open 'tmp/index.html', 'w' do |f|
  f << <<-HEREDOC
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <title>Packaged Stub Test</title>
    <style></style>
  </head>
  <body>
    <h1>Packaged Stub Test 0.1</h1>
    <button id="updateButton">Update</button>
    <div id="console"></div>
    <script type="application/javascript;version=1.8">
      document.getElementById("updateButton").addEventListener("click",
        function() update(), false);

      function notify(message) {
        var console = document.getElementById("console");
        console.appendChild(document.createTextNode(message));
        console.appendChild(document.createElement("br"));
      }

      function update() {
        var getSelf = navigator.mozApps.getSelf();

        getSelf.onsuccess = function() {
          var self = getSelf.result;

          notify("Checking for update…");
          var checkUpdate = self.checkForUpdate();

          checkUpdate.onsuccess = function() {
            if (self.downloadAvailable) {
              notify("Update available; downloading and installing update…");

              self.ondownloadsuccess = function onDownloadSuccess(event) {
                notify("Download success; closing app to complete update…");
                window.setTimeout(function() window.close(), 3000);
              };

              self.ondownloaderror = function onDownloadError() {
                notify("Download error: " + self.downloadError.name);
              };

              self.ondownloadapplied = function onDownloadApplied() {
                notify("Download applied too soon; I should have quit by now!");
              };

              self.download();

            } else {
              notify("No update available.");
            }
          };

          checkUpdate.onerror = function() {
            notify("Checking for update error: " + checkUpdate.error.name);
          }
        };

        getSelf.onerror = function() {
          notify("Get self error: " + getSelf.error.name);
        }
      }
    </script>
  </body>
</html>
  HEREDOC
end

# Create app manifest
File.open 'tmp/manifest.webapp', 'w' do |f|
  f << <<-HEREDOC
{
  "name": "#{app_name}",
  "description": "a packaged app for testing stub updates",
  "launch_path": "/index.html",
  "version": "0.1",
  "developer": {
    "name": "Myk Melez",
    "url": "https://github.com/mykmelez/packaged-app-stub"
  },
  "locales": {
    "en-US": {
      "name": "PackStubTest",
      "description": "a packaged app for testing stub updates",
      "developer": {
        "name": "Myk Melez",
        "url": "https://github.com/mykmelez/packaged-app-stub"
      }
    }
  },
  "default_locale": "en-US",
  "icons": {
    "128": "/style/icons/Blank.png"
  }
}
  HEREDOC
end


# TODO
# create other files...
# zip up files...

# clean up ./tmp
#FileUtils.rm_rf './tmp'
