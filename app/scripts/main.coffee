gameStates = {}

cursorKeys = null
ship = null

gameStates.preload = ->
    game.load.image('ship', 'assets/ship.png')

gameStates.create = ->

    game.physics.startSystem(Phaser.Physics.P2JS)
    game.physics.p2.defaultRestitution = 0.9

    ship = game.add.sprite(200, 200, 'ship')
    game.physics.p2.enable(ship)

    game.camera.follow(ship)

    cursorKeys = game.input.keyboard.createCursorKeys()

gameStates.update = ->
    if cursorKeys.left.isDown
        ship.body.rotateLeft(100)
    else if cursorKeys.right.isDown
        ship.body.rotateRight(100)
    else
        ship.body.setZeroRotation()

    if cursorKeys.up.isDown
        ship.body.thrust(100)

gameStates.render = ->

game = new Phaser.Game(800, 600, Phaser.AUTO, 'LD29', gameStates)
