arDrone = require 'ar-drone'
XboxController = require 'xbox-controller'

control = arDrone.createUdpControl()
xbox = new XboxController

deadzones =
  trigger: 40
  stick: 10000
stickMax = 32768

resetRef = -> emergency: no, fly: no
resetPcmd = -> front: 0, left: 0, up: 0, clockwise: 0
ref = resetRef()
pcmd = resetPcmd()
ref.emergency = yes

xbox.on 'not-found', ->
  console.log 'Please attach an Xbox360 controller.'
  if ref.fly is yes then ref.emergency = yes
  ref.fly = no

xbox.on 'connected', ->
  console.log 'Xbox controller connected'
  ref.emergency = no
  ref.fly = no

xbox.on 'start:press', (key) ->
  console.log 'Taking off'
  ref.fly = yes

xbox.on 'back:press', (key) ->
  console.log 'Setting down'
  ref.fly = no

xbox.on 'left:move', (position) ->
  pcmd.left = position.x / stickMax
  pcmd.front = position.y / stickMax

xbox.on 'right:move', (position) ->
  pcmd.clockwise = position.x / stickMax

xbox.on 'righttrigger', (position) ->
  pcmd.up = position / 255

xbox.on 'lefttrigger', (position) ->
  pcmd.up = -position / 255

sendUpdates = ->
  control.ref ref
  control.pcmd pcmd
  control.flush()

setInterval sendUpdates, 30
