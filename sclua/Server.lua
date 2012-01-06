local osc = require("osc")
--local funcs = require("sclua.funcs")

local Server = {}
Server.__index = Server

--------------------
-- Server Options
Server.options = {}
Server.options.path = "/Applications/LuaAV.12.12.11/"
Server.options.port = 57110

--[[
   -u <udp-port-number>    a port number 0-65535
   -t <tcp-port-number>    a port number 0-65535
   -c <number-of-control-bus-channels> (default 4096)
   -a <number-of-audio-bus-channels>   (default 128)
   -i <number-of-input-bus-channels>   (default 8)
   -o <number-of-output-bus-channels>  (default 8)
   -z <block-size>                     (default 64)
   -Z <hardware-buffer-size>           (default 0)
   -S <hardware-sample-rate>           (default 0)
   -b <number-of-sample-buffers>       (default 1024)
   -n <max-number-of-nodes>            (default 1024)
   -d <max-number-of-synth-defs>       (default 1024)
   -m <real-time-memory-size>          (default 8192)
   -w <number-of-wire-buffers>         (default 64)
   -r <number-of-random-seeds>         (default 64)
   -D <load synthdefs? 1 or 0>         (default 1)
   -R <publish to Rendezvous? 1 or 0>  (default 1)
   -l <max-logins>                     (default 64)
          maximum number of named return addresses stored
          also maximum number of tcp connections accepted
   -p <session-password>
          When using TCP, the session password must be the first command sent.
          The default is no password.
          UDP ports never require passwords, so for security use TCP.
   -N <cmd-filename> <input-filename> <output-filename> <sample-rate> <header-format> <sample-format>
   -I <input-streams-enabled>
   -O <output-streams-enabled>
   -M <server-mach-port-name> <reply-mach-port-name>
   -H <hardware-device-name>
   -v <verbosity>
          0 is normal behaviour
          -1 suppresses informational messages
          -2 suppresses informational and many error messages
   -U <ugen-plugins-path>    a colon-separated list of paths
          if -U is specified, the standard paths are NOT searched for plugins.
   -P <restricted-path>    
          if specified, prevents file-accessing OSC commands from
          accessing files outside <restricted-path>.
--]]

-----------------------------
function Server:new(IP, port)
	local srv = {}
	setmetatable(srv, Server)
	IP = IP or '127.0.0.1'
	port = port or 57110
	srv.IP = IP
	srv.port = port
	oscout = osc.Send(srv.IP, srv.port)
	-- oscin  = osc.Recv(57180) -- I need a two directional OSC port
   return srv
end

function Server:dumpOSC(mode)
-- 	I think this is buggy on the SC Server side (maybe not in 3.5)
--	0 - turn dumping OFF.
--	1 - print the parsed contents of the message.
--	2 - print the contents in hexadecimal.
--	3 - print both the parsed and hexadecimal representations of the contents.	
	oscout:send('/dumpOSC', mode)
end

function Server:boot()
	os.execute(
	   "cd " .. self.options.path
	      .. " scsynth &&"
	      .. " -u " .. self.options.port
	      ..  " -b 1026 -R 0 &"
		  ) 
end

function Server:freeAll()
	oscout:send('/g_freeAll', 0)
	oscout:send('/clearSched')
	oscout:send("/g_new", 1, 0, 0)
end

function Server:sendMsg(...)
	oscout:send(...)
end

function Server:notify(arg)
	oscout:send('/notify', arg)
end

function Server:status()
	oscout:send('/status', arg)
end

--function get_osc()
--	for msg in oscin:recv() do	
--		print(msg.addr, msg.types, unpack(msg))
--		-- add message handling here
--	end
--end
--
--go(function()
--	while(true) do
--		get_osc()
--		wait(1/40)
--	end
--end)

return Server