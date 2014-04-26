graph = {
    nodes: [
        {x:   0, y:   0},  # 0
        {x: 100, y:   0},  # 1
        {x: 200, y:   0},  # 2
        {x:   0, y: 100},  # 3
        {x: 100, y: 100},  # 4
        {x: 200, y: 100},  # 5
        {x:   0, y: 200},  # 6
        {x: 100, y: 200},  # 7
        {x: 200, y: 200},  # 8
    ]
    edges: [
        # horizontal
        [0, 1], [1, 2],
        [3, 4], [4, 5],
        [6, 7], [7, 8],
        # vertical
        [0, 3], [3, 6],
        [1, 4], [4, 7],
        [2, 5], [5, 8],
    ]

class MainState
    preload: ->

    create: ->
        t = @game.add.text(
            @game.width / 2, 0,
            'Welcome',
            style = { font: '32px Arial', fill: '#8800ff', align: 'center' }
        )
        t.anchor.set(.5, 0)
        @drawGraph()

    drawGraph: ->
        graphGraphics = @game.add.graphics(0, 0)
        graphGraphics.lineStyle(3, 0xffffff, 1.0)

        for edge in graph.edges
            [node1Index, node2Index] = edge
            node1 = graph.nodes[node1Index]
            node2 = graph.nodes[node2Index]
            graphGraphics.moveTo(node1.x, node1.y)
            graphGraphics.lineTo(node2.x, node2.y)
        return

    update: ->

    render: ->

start = ->
    game = new Phaser.Game(320, 480, Phaser.AUTO, 'LD29')
    game.state.add('main', MainState)
    game.state.start('main')

start()
