# CoffeeScriptバージョンはhanachin_が作りました
enchant.ui = assets: ['pad.png', 'apad.png']
class enchant.ui.Pad extends enchant.Sprite
  constructor: ->
    game = enchant.Game.instance
    image = game.assets['pad.png']
    super(image.width / 2, image.height)
    @image = image
    @input = left: false, right: false, up: false, down:false
    @addEventListener('touchstart', (e) ->
      @_updateInput(this._detectInput(e.localX, e.localY))
    )
    @addEventListener('touchmove', (e) ->
      @_updateInput(@_detectInput(e.localX, e.localY))
    )
    @addEventListener('touchend', (e) ->
      @_updateInput(left: false, right: false, up: false, down:false)
    )
  _detectInput: (x, y) ->
    x -= this.width / 2
    y -= this.height / 2
    input = left: false, right: false, up: false, down:false
    if (x * x + y * y > 200)
      if (x < 0 and y < x * x * 0.1 and y > x * x * -0.1)
        input.left = true
      if (x > 0 && y < x * x * 0.1 && y > x * x * -0.1)
        input.right = true
      if (y < 0 && x < y * y * 0.1 && x > y * y * -0.1)
        input.up = true
      if (y > 0 && x < y * y * 0.1 && x > y * y * -0.1)
        input.down = true
    input

  _updateInput: (input) ->
    game = enchant.Game.instance
    ['left', 'right', 'up', 'down'].forEach((type) ->
      if @input[type] && !input[type]
        game.dispatchEvent(new Event(type + 'buttonup'))
      if !@input[type] && input[type]
        game.dispatchEvent(new Event(type + 'buttondown'))
    , this)
    @input = input

class enchant.ui.APad extends enchant.Group
  constructor: (mode) ->
    game = enchant.Game.instance
    image = game.assets['apad.png']
    w = @width = image.width
    h = @height = image.height
    super
    @outside = new Sprite(w, h)
    outsideImage = new Surface(w, h)
    outsideImage.draw(image,     0,     0,   w, h/4,     0,     0,   w, h/4)
    outsideImage.draw(image,     0, h/4*3,   w, h/4,     0, h/4*3,   w, h/4)
    outsideImage.draw(image,     0,   h/4, w/4, h/2,     0,   h/4, w/4, h/2)
    outsideImage.draw(image, w/4*3,   h/4, w/4, h/2, w/4*3,   h/4, w/4, h/2)
    @outside.image = outsideImage
    @inside = new Sprite(w/2, h/2)
    insideImage = new Surface(w/2, h/2)
    insideImage.draw(image, w/4, h/4, w/2, h/2, 0, 0, w/2, h/2)
    @inside.image = insideImage
    @isTouched = false
    @r = w / 2
    @vx = 0
    @vy = 0
    @_updateImage()
    if (mode == 'direct')
      @mode = 'direct'
    else
      @mode = 'normal'

    @addChild(@inside)
    @addChild(@outside)
    @addEventListener('touchstart', (e) ->
      @_detectInput(e.localX, e.localY)
      @_calcPolar(e.localX, e.localY)
      @_updateImage(e.localX, e.localY)
      @_dispatchPadEvent('apadstart')
      @isTouched = true
    )
    @addEventListener('touchmove', (e) ->
      @_detectInput(e.localX, e.localY)
      @_calcPolar(e.localX, e.localY)
      @_updateImage(e.localX, e.localY)
      @_dispatchPadEvent('apadmove')
    )
    @addEventListener('touchend', (e) ->
      @_detectInput(@width / 2, @height / 2)
      @_calcPolar(@width / 2, @height / 2)
      @_updateImage(@width / 2, @height / 2)
      @_dispatchPadEvent('apadend')
      @isTouched = false
    )

  _dispatchPadEvent: (type) ->
    e = new Event(type)
    e.vx = @vx
    e.vy = @vy
    e.rad = @rad
    e.dist = @dist
    @dispatchEvent(e)

  _updateImage: (x, y) ->
    x -= @width / 2
    y -= @height / 2
    @inside.x = @vx * (@r - 10) + 25
    @inside.y = @vy * (@r - 10) + 25

  _detectInput: (x, y) ->
    x -= @width / 2
    y -= @height / 2
    distance = Math.sqrt(x * x + y * y)
    tan = y / x
    rad = Math.atan(tan)
    dir = x / Math.abs(x)
    if (distance is 0)
      @vx = 0
      @vy = 0
    else if (x is 0)
      @vx = 0
      if (@mode is 'direct')
        @vy = (y / @r)
      else
        dir = y / Math.abs(y)
        @vy = Math.pow((y / @r), 2) * dir
    else if (distance < @r)
      if (@mode == 'direct')
        @vx = (x / @r)
        @vy = (y / @r)
      else
        @vx = Math.pow((distance / @r), 2) * Math.cos(rad) * dir
        @vy = Math.pow((distance / @r), 2) * Math.sin(rad) * dir
    else
      @vx = Math.cos(rad) * dir
      @vy = Math.sin(rad) * dir

  _calcPolar: (x, y) ->
    x -= @width / 2
    y -= @height / 2
    add = 0
    rad = 0
    dist = Math.sqrt(x * x + y * y)
    dist = @r if dist > @r

    dist /= @r
    if (@mode == 'normal')
      dist *= dist

    if (x >= 0 && y < 0)
      add = Math.PI/2*3
      rad = x / y
    else if (x < 0 && y <= 0)
      add = Math.PI
      rad = y / x
    else if (x <= 0 && y > 0)
      add = Math.PI / 2
      rad = x / y
    else if (x > 0 && y >= 0)
      add = 0
      rad = y / x
    if (x == 0 || y == 0)
      rad = 0
    @rad = Math.abs(Math.atan(rad)) + add
    @dist = dist
