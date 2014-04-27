getEdgeKey = (nodeIndex1, nodeIndex2) ->
    if nodeIndex1 < nodeIndex2
        "#{nodeIndex1}-#{nodeIndex2}"
    else
        "#{nodeIndex2}-#{nodeIndex1}"

class @Graph
    ###
    Arguments:

    nodes = [
        {x: ..., y: ..., neighbors: {nodeId: node, ...}},
        .
        .
    ]
    faces = [
        {x: ..., y: ..., nodes: [nodeId, ...], neighbors: [faceId, ...], edgeKeys: [...]},
        .
        .
    ]
    edges = [
        [nodeId1, nodeId2], ...
    ]

    Members:

    @nodes = same as above

    @facesById: {
        faceId: face,
        .
        .
    }

    @edgesByKey = {
        edgeKey: edge,
        .
        .
    }

    @facesByEdge: {
        edgeId: [face, face?]
    }
    ###
    constructor: ({@nodes, edges, faces}) ->

        @facesById = {}
        for face, faceIndex in faces
            face.id = faceIndex
            @facesById[faceIndex] = face
        console.log 'facesById', @facesById

        # Create facesByEdge map
        # Maps edge ID to array of faces that have this edge (1 or 2)
        @facesByEdge = {}
        for faceId, face of @facesById
            face.edgeKeys = []
            for i in [0...face.nodes.length]
                nodeIndex1 = face.nodes[i]
                nodeIndex2 = face.nodes[(i + 1) % face.nodes.length]
                key = getEdgeKey(nodeIndex1, nodeIndex2)
                face.edgeKeys.push(key)
                faceList = (@facesByEdge[key] ?= [])
                faceList.push(face)

        console.log 'facesByEdge', @facesByEdge

        # Set neighbors on nodes
        for edge in edges
            [node1Index, node2Index] = edge
            node1 = @nodes[node1Index]
            node2 = @nodes[node2Index]

            node1.neighbors ?= {}
            node1.neighbors[node2Index] = node2
            node2.neighbors ?= {}
            node2.neighbors[node1Index] = node1

        @edgesByKey = {}
        for edge in edges
            edgeKey = getEdgeKey(edge[0], edge[1])
            @edgesByKey[edgeKey] = edge

    captureNodes: (nodes) ->
        points = (new Phaser.Point(@nodes[n].x, @nodes[n].y) for n in nodes)
        #points.push(points[0])
        polygon = new Phaser.Polygon(points)

        # Faces to remove
        toRemove = []

        visited = {}

        maybeDelete = (faceId) =>
            if visited[faceId]
                return

            visited[faceId] = true
            face = @facesById[faceId]
            if not face
                throw "no face with id #{faceId}"
            if polygon.contains(face.x, face.y)
                #console.log 'delete face', faceId, ', poly contains', face.x, face.y
                visited[faceId] = true
                toRemove.push(face)
                for neighborId in face.neighbors
                    maybeDelete(neighborId)
            else
                console.log faceId, 'is not inside'
            return

        firstFaces = @facesByEdge[getEdgeKey(nodes[0], nodes[1])]
        maybeDelete(firstFaces[0].id)
        if firstFaces.length > 1
            maybeDelete(firstFaces[1].id)

        console.log 'Removing faces...'
        for face in toRemove
            @removeFace(face)

        return

    removeFace: (face) ->
        console.log 'Removing face', face.id
        for edgeKey in face.edgeKeys
            neighbors = @facesByEdge[edgeKey]
            if neighbors.length == 1
                # This face was the only one using this edge
                console.log '...removing edge', edgeKey
                @removeEdge(edgeKey)
            else if neighbors.length == 2
                neighbor = neighbors[if neighbors[0] == face then 1 else 0]
                console.log '...removing from edge', edgeKey, 'only', neighbor.id, 'left'
                @facesByEdge[edgeKey] = [neighbor]
            else
                throw "Unexpected number of faces on edge #{edgeKey}: #{neighbors.length}"

        for neighborId in face.neighbors
            neighbor = @facesById[neighborId]
            neighbor.neighbors = (n for n in neighbor.neighbors when n != face.id)
        delete @facesById[face.id]
        return

    removeEdge: (edgeKey) ->
        delete @facesByEdge[edgeKey]
        delete @edgesByKey[edgeKey]
        nodeIds = edgeKey.split('-')

        # Remove neighbor connections
        nodeId0 = +nodeIds[0]
        nodeId1 = +nodeIds[1]
        console.log '......old neighbors from', nodeId0, @nodes[nodeId0].neighbors
        console.log '......old neighbors from', nodeId1, @nodes[nodeId1].neighbors
        delete @nodes[nodeId0].neighbors[nodeId1]
        delete @nodes[nodeId1].neighbors[nodeId0]
        console.log '......new neighbors from', nodeId0, @nodes[nodeId0].neighbors
        console.log '......new neighbors from', nodeId1, @nodes[nodeId1].neighbors

