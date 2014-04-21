tweaks =
    turn: 100
    thrust: 180
    gravity: -2
    particleGravity: 100

class Main

    preload: ->
        game.load.image('ship', 'assets/ship.png')
        game.load.image('exhaust', 'assets/exhaust.png')
        game.load.image('tiles', 'assets/tiles.png')
        game.load.tilemap('map', 'assets/map.json', null, Phaser.Tilemap.TILED_JSON)

    create: ->
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
        @ship = game.add.sprite(200, 200, 'ship')
        game.physics.p2.enable(@ship)

        game.camera.follow(@ship)

        # Controls
        @cursorKeys = game.input.keyboard.createCursorKeys()

    update: ->
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
            @thrusting = true
        else
            if @thrusting
                @thrusting = false
                # "Stop" the emitter by setting a long interval
                @exhaustEmitter.start(false, 0, 1e9)

        a = @ship.body.angle / 180 * Math.PI
        xOffset = -Math.sin(a) * 16
        yOffset = Math.cos(a) * 16
        @exhaustEmitter.emitX = @ship.position.x + xOffset
        @exhaustEmitter.emitY = @ship.position.y + yOffset
        xSpeed = -Math.sin(a) * tweaks.thrust + @ship.body.velocity.x
        ySpeed = Math.cos(a) * tweaks.thrust + @ship.body.velocity.y
        @exhaustEmitter.setXSpeed(xSpeed - 40, xSpeed + 40)
        @exhaustEmitter.setYSpeed(ySpeed - 40, ySpeed + 40)

        particlesToDestroy = []
        game.physics.arcade.collide(@exhaustEmitter, @layer, (particle, tile) ->
            particlesToDestroy.push(particle)
        )
        p.destroy() for p in particlesToDestroy
        return

    render: ->

main = new Main
game = new Phaser.Game(800, 600, Phaser.AUTO, 'LD29',
    preload: -> main.preload()
    create: -> main.create()
    update: -> main.update()
    render: -> main.render()
)
