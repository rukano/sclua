local osc = require("osc")
local
function tobinary (b)
   if b then return 1 else return 0 end
end
local Server = {}

Server.__index = Server

--------------------
-- Server Options

Server.options = {}
Server.options.path = "/Applications/LuaAV.12.12.11/"
Server.options.ip = '127.0.0.1'
Server.options.port = 57110
Server.options.numAudioBusChannels = 128
Server.options.numControlBusChannels = 4096
Server.options.numInputBusChannels = 2
Server.options.numOutputBusChannels = 2
Server.options.numBuffers = 1026
Server.options.maxNodes = 1024
Server.options.maxSynthDefs = 1024
Server.options.protocol = 'u' -- u for utp, t for tcp
Server.options.blockSize = 64
Server.options.hardwareBufferSize = nil
Server.options.memSize = 32768
Server.options.numRGens = 64
Server.options.numWireBufs = 64
Server.options.sampleRate = nil
Server.options.loadDefs = false
Server.options.verbosity = 0
Server.options.zeroConf = false
Server.options.device = nil
Server.options.pluginsPath = nil

-- possible future options to use:
-- Server.options.inputStreamsEnabled = nil
-- Server.options.outputStreamsEnabled = nil
-- Server.options.blockAllocClass = nil
-- Server.options.restrictedPath = nil
-- Server.options.initialNodeID = 1000
-- Server.options.remoteControlVolume = false
-- Server.options.memoryLocking = false


-- scsynth unused options :

-- -l <max-logins>                     (default 64)
-- maximum number of named return addresses stored
-- also maximum number of tcp connections accepted
-- -p <session-password>
-- When using TCP, the session password must be the first command sent.
-- The default is no password.
-- UDP ports never require passwords, so for security use TCP.
-- -N <cmd-filename> <input-filename> <output-filename> <sample-rate> <header-format> <sample-format> -- nonrealtime
-- -I <input-streams-enabled>
-- -O <output-streams-enabled>
-- -M <server-mach-port-name> <reply-mach-port-name>
-- -P <restricted-path>    
-- if specified, prevents file-accessing OSC commands from
-- accessing files outside <restricted-path>.

function Server:boot()
   local o = self.options
   local cmd =
      "cd " .. o.path
      .. " && scsynth "
      .. " -" .. o.protocol .. " " .. o.port
      .. " -c " .. o.numControlBusChannels
      .. " -a " .. o.numAudioBusChannels
      .. " -i " .. o.numInputBusChannels
      .. " -o " .. o.numOutputBusChannels
      .. " -z " .. o.blockSize
      .. " -Z " .. (o.hadwareBufferSize or 0)
      .. " -S " .. (o.sampleRate or 0)
      .. " -b " .. o.numBuffers
      .. " -n " .. o.maxNodes
      .. " -d " .. o.maxSynthDefs
      .. " -m " .. o.memSize
      .. " -w " .. o.numWireBufs
      .. " -r " .. o.numRGens
      .. " -D " .. tobinary(o.loadDefs)
      .. " -R " .. tobinary(o.zeroConf)
      .. " -v " .. o.verbosity

   if o.device then
      cmd = cmd .. " -H " .. '\"'..  o.device .. '\"'  -- enquote?
   end

   if o.pluginsPath then
      cmd = cmd .. " -U " .. o.pluginsPath
   end

   cmd = cmd .." &" -- run in background
   
   os.execute(cmd) 
end


function Server:new(IP, port)
	local srv = {}
	setmetatable(srv, Server)
	local IP = IP or self.ip
	local port = port or self.port
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