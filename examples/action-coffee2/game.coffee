enchant()

class Bear extends Sprite
  constructor: (w, h, image) ->
    super 32, 32
    @image = Game.instance.assets[image]
    @x = 0
    @y = 0

  enterframe: (e) ->
    @x = @x + 1

game = new Game(320, 320)
game.fps = 24
game.preload('chara1.gif')

game.onload = ->
  bear = new Bear(32, 32, "chara1.gif")
  game.rootScene.addChild(bear)

game.start()
