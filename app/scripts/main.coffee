class Snake
    constructor: (@graph, startNode, nextNode) ->
        @nodes = [nextNode, startNode]
        @headDistance = 0
        @tailDistance = 0
        @nextNode = null

    move: (distance) ->
        @headDistance += distance
        edgeLength = @getEdgeLength()
        if @headDistance >= edgeLength
            if @nextNode == null
                @headDistance = edgeLength
                head = @getHeadNode()
                candidateNeighbors = (+i for i, n of head.neighbors when +i != @nodes[1])
                @nextNode = candidateNeighbors[Math.floor(Math.random() * candidateNeighbors.length)]
                #console.log 'candiates with neighbors ', head.neighbors, 'nodes', @nodes[0..3], ':', candidateNeighbors, 'picking', n

            @headDistance -= edgeLength
            #console.log 'Switching towards node', @nextNode
            @nodes.unshift(@nextNode)
            @nextNode = null

    getHeadNode: -> @graph.nodes[@nodes[0]]
    getNeckNode: -> @graph.nodes[@nodes[1]]

    # Get the length of the current edge
    getEdgeLength: ->
        headNode = @getHeadNode()
        neckNode = @getNeckNode()
        return Math.sqrt(
            Math.pow(headNode.x - neckNode.x, 2) +
            Math.pow(headNode.y - neckNode.y, 2)
        )

    getHeadPosition: ->
        headNode = @getHeadNode()
        neckNode = @getNeckNode()
        fraction = @headDistance / @getEdgeLength()
        return {
            x: neckNode.x + fraction * (headNode.x - neckNode.x),
            y: neckNode.y + fraction * (headNode.y - neckNode.y)
        }

graph = {
    nodes: [
        {x:   0, y:   0},  # 0
        {x: 100, y:   0},  # 1
        {x: 250, y:   0},  # 2
        {x:   0, y: 100},  # 3
        {x: 100, y: 100},  # 4
        {x: 250, y: 100},  # 5
        {x:   0, y: 200},  # 6
        {x: 100, y: 200},  # 7
        {x: 200, y: 150},  # 8
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
}

for edge in graph.edges
    [node1Index, node2Index] = edge
    node1 = graph.nodes[node1Index]
    node2 = graph.nodes[node2Index]

    node1.neighbors ?= {}
    node1.neighbors[node2Index] = node2
    node2.neighbors ?= {}
    node2.neighbors[node1Index] = node1


class MainState
    preload: ->
        @game.load.image('head', 'assets/head.png')

    create: ->
        @graphGraphics = @game.add.graphics(0, 0)
        @graphGraphics.lineStyle(1, 0x880088, 1.0)
        @drawGraph()
        @graphGraphics.lineStyle(3, 0xffffff, 1.0)

        @snake = new Snake(graph, 0, 1)
        @snake.nextNode = 4
        @snake.sprite = @game.add.sprite(20, 20, 'head')
        @snake.sprite.anchor.set(.5, .5)

        @game.input.onDown.add(
            (pointer, mouseEvent) ->
                #console.log 'down', arguments
                @select(pointer.x, pointer.y)
            this
        )

    select: (x, y) ->
        head = @snake.getHeadNode()
        for neighborIndex, neighbor of head.neighbors
            if (Math.pow(neighbor.x - x, 2) + Math.pow(neighbor.y - y, 2)) < (Math.pow(20, 2))
                @graphGraphics.drawCircle(neighbor.x, neighbor.y, 20)
                console.log 'heading towards', neighborIndex
                @snake.nextNode = neighborIndex
                return

    drawGraph: ->
        for edge in graph.edges
            [node1Index, node2Index] = edge
            node1 = graph.nodes[node1Index]
            node2 = graph.nodes[node2Index]
            @graphGraphics.moveTo(node1.x, node1.y)
            @graphGraphics.lineTo(node2.x, node2.y)
        return

    update: ->
        pos = @snake.getHeadPosition()
        @graphGraphics.moveTo pos.x, pos.y
        @snake.move(1)
        pos = @snake.getHeadPosition()
        @snake.sprite.position.set(pos.x, pos.y)
        @graphGraphics.lineTo pos.x, pos.y

    render: ->

start = ->
    game = new Phaser.Game(320, 480, Phaser.AUTO, 'LD29')
    game.state.add('main', MainState)
    game.state.start('main')

start()
