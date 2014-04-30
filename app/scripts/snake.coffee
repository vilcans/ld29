class @Snake
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
            moved = @goToNextNode()
            if moved
                @headDistance -= edgeLength
            else
                # Nowhere to go: stop
                @headDistance = edgeLength

    goToNextNode: ->
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

        if @nextNode? and not @graph.nodes[@nextNode].neighbors[@nodes[0]]
            # No edge between these nodes
            console.log 'nextNode not valid any more'
            @nextNode = null

        if @nextNode == null
            nextCandidates = (+n for n of @graph.nodes[@nodes[0]].neighbors when +n != neckId)
            if nextCandidates.length == 0
                console.log 'No possible next node'
            else
                @nextNode = nextCandidates[_.random(nextCandidates.length - 1)]
                console.log 'Randomly chose', @nextNode

        @onNodeTraversed(headId, neckId, @nextNode)
        if @nextNode == null
            @headDistance = edgeLength
            return false

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
