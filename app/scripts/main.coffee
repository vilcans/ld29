tweaks =
    turn: 100
    thrust: 250
    gravity: -4
    particleGravity: 100
    debugPhysics: false
    exhaustSpeed: 30

center = (sprite) ->
    sprite.position.x = 400 - sprite.width / 2
    return sprite

# For documentation about states, see
# https://github.com/photonstorm/phaser/wiki/Phaser-General-Documentation-:-States

class InGameState

    preload: ->
        Tracking.trackEvent 'ingame', 'preload'

        game = @game
        game.load.image('ship', 'assets/ship.png')
        game.load.image('exhaust', 'assets/exhaust.png')
        game.load.image('tiles', 'assets/tiles.png')
        game.load.tilemap('map', 'assets/map.json', null, Phaser.Tilemap.TILED_JSON)

        game.load.audio('engine', ['assets/engine.ogg'])

        game.load.physics('physicsData', 'assets/shapes.json')

    create: ->
        Tracking.trackEvent 'ingame', 'create'

        game = @game
        game.physics.startSystem(Phaser.Physics.P2JS)
        game.physics.p2.world.gravity = [0, tweaks.gravity]

        # Exhaust particles
        # Add before Tilemap so they are behind it
        @exhaustEmitter = game.add.emitter(0, 0, 50)
        @exhaustEmitter.makeParticles('exhaust')
        @exhaustEmitter.gravity = tweaks.particleGravity

        # Tilemap
        @tilemap = game.add.tilemap('map')
        @tilemap.addTilesetImage('tiles')
        @tilemap.setCollisionByExclusion([1])
        @tileLayer = @tilemap.createLayer('Tile Layer 1')
        @tileLayer.resizeWorld()
        game.physics.p2.convertTilemap(@tilemap, @tileLayer)

        # Ship
        @ship = game.add.sprite(50, 50, 'ship')
        game.physics.p2.enable(@ship, tweaks.debugPhysics)
        @ship.body.clearShapes()
        @ship.body.addPhaserPolygon('physicsData', 'ship')
        @ship.body.onBeginContact.add(@shipHit, this)

        game.camera.follow(@ship)

        # Controls
        @cursorKeys = game.input.keyboard.createCursorKeys()

        # Audio
        @engineSound = game.add.audio('engine', 1, true)

    shipHit: ->
        @engineSound.stop()
        Tracking.trackEvent 'ingame', 'shipHit'
        @game.state.start('over')

    update: ->
        game = @game

        cursorKeys = @cursorKeys
        if cursorKeys.left.isDown
            @ship.body.rotateLeft(tweaks.turn)
        else if cursorKeys.right.isDown
            @ship.body.rotateRight(tweaks.turn)
        else
            @ship.body.setZeroRotation()

        if cursorKeys.up.isDown
            @ship.body.thrust(tweaks.thrust)
            if not @thrusting
                @exhaustEmitter.start(false, 500, 10, 0)
                @engineSound.play('', undefined, undefined, true)
            @thrusting = true
        else
            if @thrusting
                @thrusting = false
                # "Stop" the emitter by setting a long interval
                @exhaustEmitter.start(false, 0, 1e9)
                @engineSound.stop()

        a = @ship.body.angle / 180 * Math.PI
        xOffset = -Math.sin(a) * 16
        yOffset = Math.cos(a) * 16
        @exhaustEmitter.emitX = @ship.position.x + xOffset
        @exhaustEmitter.emitY = @ship.position.y + yOffset
        xSpeed = -Math.sin(a) * tweaks.thrust + @ship.body.velocity.x
        ySpeed = Math.cos(a) * tweaks.thrust + @ship.body.velocity.y
        @exhaustEmitter.setXSpeed(xSpeed - 40, xSpeed + 40)
        @exhaustEmitter.setYSpeed(ySpeed - 40, ySpeed + 40)
        @exhaustEmitter.addAll('alpha', -.02)

        game.physics.arcade.collide(@exhaustEmitter, @tileLayer, (particle, tile) ->
            particle.alpha *= .5
        )
        return

    render: ->

class MenuState
    create: ->
        Tracking.trackEvent 'menu', 'create'

        center(
            @game.add.text(
                0, 40,
                'Collide and Die',
                style = { font: '32px Arial', fill: '#8800ff', align: 'center' }
            )
        )
        center(
            @game.add.text(
                0, 86,
                'Left and right arrow keys to turn. Up for thrust.\n' +
                'There is no winning this. Just me, Martin Vilcans, warming up for Ludum Dare 29',
                style = { font: '16px Arial', fill: '#8800ff', align: 'center' }
            )
        )

        @startButton = center(
            @game.add.text(
                0, 450,
                'Start',
                style = { font: '32px Arial', fill: '#8800ff', align: 'center' }
            )
        )
        @startButton.inputEnabled = true
        @startButton.events.onInputDown.add(
            (object, pointer) ->
                @game.state.start('ingame')
            this
        )

class GameOverState
    create: ->
        Tracking.trackEvent 'over', 'create'

        center(@game.add.text(
            0, 40,
            'Game Over',
            style = { font: '32px Arial', fill: '#ffffff', align: 'center' }
        ))
        @restartButton = center(@game.add.text(
            0, 450,
            'Restart',
            style = { font: '32px Arial', fill: '#8800ff', align: 'center' }
        ))
        @restartButton.inputEnabled = true
        @restartButton.events.onInputDown.add(
            (object, pointer) ->
                @game.state.start('menu')
            this
        )

start = ->
    game = new Phaser.Game(800, 600, Phaser.AUTO, 'LD29')
    game.state.add('ingame', InGameState)
    game.state.add('menu', MenuState)
    game.state.add('over', GameOverState)
    game.state.start('menu')

start()
