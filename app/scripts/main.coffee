class MainState
    preload: ->

    create: ->

    update: ->

    render: ->

start = ->
    game = new Phaser.Game(800, 600, Phaser.AUTO, 'LD29')
    game.state.add('main', MainState)
    game.state.start('main')

start()
