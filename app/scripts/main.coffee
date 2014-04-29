class Snake
    constructor: (@graph, startNode, nextNode) ->
        @nodes = [nextNode, startNode]
        @headDistance = 0
        @tailDistance = 0
        @nextNode = null
        @isAlive = true
        @maxSegments = 3
        @onNodeTraversed = (previousNode, acrossNode, nextNode) ->

    canMove: ->
        @isAlive and @nodes.length >= 2

    kill: ->
        @isAlive = false

    move: (distance) ->
        if not @canMove()
            console.log 'cannot move'
            return false

        @headDistance += distance
        edgeLength = @getEdgeLength(0)

        if @headDistance >= edgeLength

            headId = @nodes[0]
            neckId = @nodes[1]

            i = @nodes.length
            while --i >= 1
                if @nodes[i] == @nodes[0]
                    closedLoop = @nodes[..i]
                    console.log 'Hit myself in nodes', closedLoop
                    console.log 'nodes are', @nodes
                    @graph.captureNodes(closedLoop)
                    @nodes = [@nodes[0]]
                    break

            if @nextNode? and not graph.nodes[@nextNode].neighbors[@nodes[0]]
                # No edge between these nodes
                console.log 'nextNode not valid any more'
                @nextNode = null

            if @nextNode == null
                nextCandidates = (+n for n of graph.nodes[@nodes[0]].neighbors when +n != neckId)
                if nextCandidates.length == 0
                    console.log 'No possible next node'
                else
                    @nextNode = nextCandidates[_.random(nextCandidates.length - 1)]
                    console.log 'Randomly chose', @nextNode

            @onNodeTraversed(headId, neckId, @nextNode)
            if @nextNode == null
                @headDistance = edgeLength
                return

            @headDistance -= edgeLength
            #console.log 'Switching towards node', @nextNode
            @nodes.unshift(@nextNode)
            if @nodes.length > @maxSegments + 1
                @nodes.pop()
            @nextNode = null

        return true

    # Get the node that this snake is moving towards
    getHeadNode: -> @graph.nodes[@nodes[0]]

    # Get the node that this snake just moved over
    getNeckNode: -> @graph.nodes[@nodes[1]]

    getTailNode: -> @graph.nodes[@nodes[@nodes.length - 1]]

    getTailBaseNode: -> @graph.nodes[@nodes[@nodes.length - 2]]

    # Get the length of an edge
    # segmentIndex is the segment to check, 0 for head to neck,
    # 1 for neck to next segment etc.
    getEdgeLength: (segmentIndex) ->
        node1 = @graph.nodes[@nodes[segmentIndex]]
        node2 = @graph.nodes[@nodes[segmentIndex + 1]]
        return Math.sqrt(
            Math.pow(node1.x - node2.x, 2) +
            Math.pow(node1.y - node2.y, 2)
        )

    getHeadPosition: ->
        headNode = @getHeadNode()
        neckNode = @getNeckNode()
        unless neckNode
            return {
                x: headNode.x
                y: headNode.y
            }
        fraction = @headDistance / @getEdgeLength(0)
        return {
            x: neckNode.x + fraction * (headNode.x - neckNode.x),
            y: neckNode.y + fraction * (headNode.y - neckNode.y)
        }
###
graph = new Graph(
    nodes: [
        {x:  20, y:  20},  # 0   neighbors: {nodeId: node, ...}
        {x: 200, y:  20},  # 1
        {x: 500, y:  20},  # 2
        {x:  20, y: 200},  # 3
        {x: 200, y: 200},  # 4
        {x: 500, y: 200},  # 5
        {x:  20, y: 400},  # 6
        {x: 200, y: 800},  # 7
        {x: 400, y: 380},  # 8
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
    faces: [
        {x: 100, y: 100, nodes: [0, 1, 4, 3], neighbors: [1, 2]},  # edgeKeys: [...]
        {x: 300, y: 100, nodes: [1, 2, 5, 4], neighbors: [0, 3]},
        {x: 100, y: 400, nodes: [3, 4, 7, 6], neighbors: [0, 3]},
        {x: 300, y: 300, nodes: [4, 5, 8, 7], neighbors: [1, 2]},
    ]
)
###

graph = new Graph(window.graphData.layer1)

tempPoint = new Phaser.Point
tempPoint2 = new Phaser.Point

class Layer
    constructor: (@game, @name) ->
        @bitmap = @game.add.bitmapData(@game.world.width, @game.world.height)
        @bitmap.draw(@name, 0, 0)
        @sprite = @game.add.sprite(0, 0, @bitmap)

center = (sprite) ->
    sprite.position.x = 320 / 2
    sprite.anchor.x = .5
    sprite.fixedToCamera = true
    return sprite

class IntroState
    create: ->
        Tracking.trackEvent 'state', 'intro'

        center @game.add.text(
            0, 20,
            'Skin Deep',
            { font: '32px Arial', fill: '#ffdec0', align: 'center' }
        )

        center @game.add.text(
            0, 56,
            'by Martin Vilcans\nfor Ludum Dare 29',
            { font: '12px Arial', fill: '#9a7e45', align: 'center' }
        )

        t = center @game.add.text(
            0, 240,
            [
                'Beauty may deceive.',
                'Lose that skin. I want to see your true self.',
            ].join('\n')
            { font: '12px Arial', fill: '#cccccc', align: 'center' }
        )
        t.anchor.y = .5

        t = center @game.add.text(
            0, 460,
            [
                'Guide the laser cutter by pointing.',
                'Don\'t get caught in a dead end.',
                'Touch me when ready for surgery.'
            ].join('\n')
            { font: '16px Arial', fill: '#9a7e45', align: 'center' }
        )
        t.anchor.y = 1

        @game.input.onDown.add(
            -> @game.state.start('main')
            this
        )


class MainState
    preload: ->
        @game.load.image('head', 'assets/head.png')
        @game.load.image('layer1', 'assets/layer1.png')
        @game.load.image('background', 'assets/background.jpg')
        @game.load.image('layer2', 'assets/layer2.png')

        @game.load.audio('faceoff', ['assets/faceoff.ogg'])
        @game.load.audio('enlong', ['assets/enlong.ogg'])
        @game.load.audio('death', ['assets/death.ogg'])
        @game.load.audio('music', ['assets/music.ogg'])

    create: ->
        Tracking.trackEvent 'state', 'main'

        @traversedNodes = []

        graph = new Graph(window.graphData.layer1)

        @facesRecentlyRemoved = 0

        @game.world.setBounds(0, 0, 608, 906)

        @backgroundSprite = @game.add.tileSprite(0, 0, @game.width, @game.height, 'background')
        @backgroundSprite.fixedToCamera = true

        @layer2Sprite = @game.add.sprite(0, 0, 'layer2')

        @layer = new Layer(@game, 'layer1')

        graph.onRemoveFace = (face) =>
            @facesRecentlyRemoved++
            context = @layer.bitmap.context
            # See http://stackoverflow.com/questions/8445668/how-do-you-clear-a-polygon-shaped-region-in-a-canvas-element
            context.fillStyle = 'rgba(0, 0, 0, 1.0)'
            context.globalCompositeOperation = 'destination-out'
            context.beginPath()

            for nodeId, i in face.nodes
                # Move the coordinates 1 pixel away from center
                # to paint over the fringes from antialiasing
                x = graph.nodes[nodeId].x
                y = graph.nodes[nodeId].y
                tempPoint.set(x - face.x, y - face.y)
                tempPoint.normalize()
                x += tempPoint.x
                y += tempPoint.y

                if i == 0
                    context.moveTo(x, y)
                else
                    context.lineTo(x, y)

            context.fill()
            @layer.bitmap.dirty = true

        @graphGraphics = @game.add.graphics(0, 0)
        @drawGraph()

        @selectedEdgeGraphics = @game.add.graphics(0, 0)

        @snakeGraphics = @game.add.graphics(0, 0)

        @snake = new Snake(graph, 0, 1)
        @snake.nextNode = 4
        @snake.onNodeTraversed = (previousNode, acrossNode, nextNode) =>
            #console.log 'Move:', previousNode, '-', acrossNode, 'towards', nextNode
            @traversedNodes.push(acrossNode)

        @snake.sprite = @game.add.sprite(20, 20, 'head')
        @snake.sprite.anchor.set(.5, .5)

        @game.camera.follow(@snake.sprite)

        @sounds = {
            faceoff: @game.add.audio('faceoff', 1, false)
            enlong: @game.add.audio('enlong', 1, false)
            death: @game.add.audio('death', 1, false)
            music: @game.add.audio('music', 1, true)
        }
        @sounds.music.play()

        #@game.input.onDown.add(
        #    (event) ->
        #        @select(event.worldX, event.worldY)
        #    this
        #)

    select: (x, y) ->
        head = @snake.getHeadNode()
        distanceSquared = Math.pow(head.x - x, 2) + Math.pow(head.y - y, 2)
        #if distanceSquared > 50 * 50 or distanceSquared < 10 * 10
        #    return
        directionToPointer = Phaser.Point.subtract({x: x, y: y}, head, tempPoint)
        directionToPointer.normalize()
        directionToNode = tempPoint2

        bestNodeIndex = null
        bestScore = -1.1
        for neighborIndex, neighbor of head.neighbors
            neighborIndex = +neighborIndex
            if neighborIndex == @snake.nodes[1]
                # Can't go back
                continue

            Phaser.Point.subtract neighbor, head, directionToNode
            directionToNode.normalize()
            dotprod = directionToNode.x * directionToPointer.x + directionToNode.y * directionToPointer.y
            if dotprod > bestScore
                bestScore = dotprod
                bestNodeIndex = neighborIndex

        if bestNodeIndex != null
            #console.log 'best node', bestNodeIndex, 'score', bestScore
            @snake.nextNode = bestNodeIndex

            next = graph.nodes[@snake.nextNode]
            @selectedEdgeGraphics.clear()
            @selectedEdgeGraphics.lineStyle(3, 0x888888, .8)
            headPos = @snake.getHeadPosition()
            @selectedEdgeGraphics.moveTo(headPos.x, headPos.y)
            @selectedEdgeGraphics.lineTo(head.x, head.y)
            @selectedEdgeGraphics.lineTo(next.x, next.y)

        return

    drawGraph: ->
        @graphGraphics.clear()
        @graphGraphics.lineStyle(2, 0x444444, .5)
        for edgeId, edge of graph.edgesByKey
            [node1Index, node2Index] = edge
            node1 = graph.nodes[node1Index]
            node2 = graph.nodes[node2Index]
            @graphGraphics.moveTo(node1.x, node1.y)
            @graphGraphics.lineTo(node2.x, node2.y)
        for faceId, face of graph.facesById
            @graphGraphics.drawCircle(face.x, face.y, 5)
        return

    update: ->
        try
            @_tryUpdate()
        catch e
            console.error 'Failed:', e
            info = e + ' state:' + @getStateInformation()
            Tracking.trackEvent 'error', 'update-exception', info
            throw e

    getStateInformation: =>
        return @traversedNodes.join('-')

    _tryUpdate: ->
        @moveSnake()
        @drawGraph()
        @drawSnake()
        @backgroundSprite.tilePosition.x = Math.round(@game.camera.x * -.5)
        @backgroundSprite.tilePosition.y = Math.round(@game.camera.y * -.5)

        if @facesRecentlyRemoved != 0
            count = @facesRecentlyRemoved
            Tracking.trackEvent 'game', 'deface', value: count
            @facesRecentlyRemoved = 0

            @snake.maxSegments += count
            for i in [0...count]
                @game.time.events.add(
                    200 + i * 150,
                    ->
                        if @snake.isAlive
                            @sounds.enlong.play()
                    this
                )
            @sounds.faceoff.play()

            if _.isEmpty(graph.facesById)
                @success()

    success: ->
        Tracking.trackEvent 'success', 'wee'
        @game.time.events.add(
            500,
            ->
                t = center(@game.add.text(
                    0, 460,
                    'There is no soul. Don\'t try again.',
                    { font: '16px Arial', fill: '#ffffff', align: 'center' }
                ))
                t.anchor.y = 1
                @game.input.onDown.add(
                    -> @game.state.start('intro')
                    this
                )
            this
        )


    moveSnake: ->
        if @snake.canMove()
            @snake.move(1)
        else if @snake.isAlive
            @sounds.music.stop()
            @sounds.death.play()
            @snake.kill()
            @game.time.events.add(
                500,
                ->
                    t = center(@game.add.text(
                        0, 460,
                        'A soul is hard to find.\nTry again.'
                        { font: '16px Arial', fill: '#ffffff', align: 'center' }
                    ))
                    t.anchor.y = 1
                    @game.input.onDown.add(
                        -> @game.state.start('intro')
                        this
                    )
                this
            )
            Tracking.trackEvent 'failure', 'noes'

        @select @game.input.worldX, @game.input.worldY

    drawSnake: ->
        pos = @snake.getHeadPosition()
        @snake.sprite.position.set(pos.x, pos.y)

        @snakeGraphics.clear()
        @snakeGraphics.lineStyle(3, 0xff2200, .75)
        @snakeGraphics.moveTo pos.x, pos.y
        # Drawing a line of length 0 makes the *next* line disappear,
        # hence the check for headDistance
        for i in [(if @snake.headDistance > 0 then 1 else 2)...@snake.nodes.length]
            node = graph.nodes[@snake.nodes[i]]
            @snakeGraphics.lineTo(node.x, node.y)

        return

    render: ->

start = ->
    Tracking.trackEvent 'state', 'starting'
    game = new Phaser.Game(320, 480, Phaser.AUTO, 'game')
    game.state.add('main', MainState)
    game.state.add('intro', IntroState)
    game.state.start('intro')

start()
