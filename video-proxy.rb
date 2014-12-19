require 'webrick'
require 'webrick/httpproxy'

# OSX specific - change for other notifers on other systems
require 'terminal-notifier'


# OSX specific -
COMMANDS = [
	'open -a VLC "%s"',                                                                                                             # playback using VLC
	'echo "curl -O \"%s\"" | pbcopy',                                                                                               # copy CURL command to clipboard
	'terminal-notifier -title "Downloadcommand is in the clipboard" -message "Open a console and press CMD+V to download the file"' # notify the user
]

class VideoProxy < WEBrick::HTTPProxyServer

	@@filetypes = ["mp4", "flv", "avi", "ogm"]
	@@download_folder = "~/Downloads/"

	# Port is 8000 and it takes at least 5 secs between two videos 
	def initialize(port=8000, timeout=5)
		super(Port: port, AccessLog: [], ErrorLog: [])
		@timeout = timeout
		@last_time = 0 
	end

	def service(req, res)

		uri = res.request_uri
		if @@filetypes.any? { |file_type| uri.path.end_with? file_type }  then
			puts "\n\n>>> #{uri}"
			unless ((Time.now.to_i - @last_time) < @timeout) then
				@last_time = Time.now.to_i
				show_notification(uri.to_s, req.header["referer"].first)
			end
		else
			super(req,res)
		end
	end


	def show_notification(video_url, referer)
		tmp_file = "/tmp/" + (0...50).map { ('a'..'z').to_a[rand(26)] }.join + ".command"
		File.open(tmp_file, 'w')  { |f|
			f.puts "#! /bin/sh"
			COMMANDS.each do |cmd|
				f.puts cmd.gsub("%s", video_url).gsub("%r", referer)
			end
		}
		system("chmod +x #{tmp_file}")
		host = URI(referer).host

 		# OSX specific - change for other OSes
		TerminalNotifier.notify("Watch " + video_url , :title => "Video from " + host, :execute => "open #{tmp_file}")
	end
end

port  = ((!ARGV.empty?) and (ARGV[0].to_i > 1024)) ? ARGV[0].to_i : 8000
proxy = VideoProxy.new port

trap 'INT'  do proxy.shutdown end
trap 'TERM' do proxy.shutdown end

proxy.start
