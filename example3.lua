Server = require('sclua.Server')
Synth = require('sclua.Synth')

s = Server:new()
s:boot()

go(2, function ()
      print("loading synths")
      s:loadDir("/Users/rukano/Library/Application\ Support/SuperCollider/synthdefs")
      wait(1)
      a = Synth:new("default")
      wait(1)
      a:set{"gate", 0}
      wait(1)
      a:free()
end)
