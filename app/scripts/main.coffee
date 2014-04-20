tweaks =
    turn: 100
    thrust: 180
    gravity: -2

gameStates = {}

cursorKeys = null
ship = null

gameStates.preload = ->
    game.load.image('ship', 'assets/ship.png')
    game.load.image('tiles', 'assets/tiles.png')
    game.load.tilemap('map', 'assets/map.json', null, Phaser.Tilemap.TILED_JSON)

gameStates.create = ->
    game.physics.startSystem(Phaser.Physics.P2JS)
    game.physics.p2.world.gravity = [0, tweaks.gravity]

    map = game.add.tilemap('map')
    map.addTilesetImage('tiles')
    map.setCollisionByExclusion([1])
    layer = map.createLayer('Tile Layer 1')
    layer.resizeWorld()
    game.physics.p2.convertTilemap(map, layer)

    ship = game.add.sprite(200, 200, 'ship')
    game.physics.p2.enable(ship)

    game.camera.follow(ship)

    cursorKeys = game.input.keyboard.createCursorKeys()

gameStates.update = ->
    if cursorKeys.left.isDown
        ship.body.rotateLeft(tweaks.turn)
    else if cursorKeys.right.isDown
        ship.body.rotateRight(tweaks.turn)
    else
        ship.body.setZeroRotation()

    if cursorKeys.up.isDown
        ship.body.thrust(tweaks.thrust)

gameStates.render = ->

game = new Phaser.Game(800, 600, Phaser.AUTO, 'LD29', gameStates)
