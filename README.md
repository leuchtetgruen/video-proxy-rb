video-proxy-rb
==============

A HTTP-Proxy that allows to watch videos in VLC or download them or do other things.

The proxy runs on port 8000. Add it to your browser and whenever a video (determined
by the .mp4, .flv, .avi or .ogm extension) should be loaded the proxy intercepts and
instead of delivering the video shows a notification offering you to watch the video
in VLC and copy the CURL-Download command to the clipboard.

You can change the port it is listening on by adding a command line parameter to the
call like this:

`ruby video-proxy.rb 2342`


This program requires the following ruby gems:

* webrick
* terminal-notifier

This proxy currently only works on OSX but it only takes little changes to make it
run on other platforms. You'd only need to exchange the notfification system and
adjust the commands as described below.

You can easily modify the `COMMANDS`-array in order to change what should be done
once the user clicks a video notification. The `%s` reflects the video URL whereas
`%r` is the referer URL.

