window.graphData = window.graphData || {};

// Simple single polygon for debugging
window.graphData['debug'] = {
	"edges": [[0,1], [1,2], [2,0]],
	"faces": [
		{"id": 0, "neighbors": [], "nodes": [0,1,2], "x": 25, "y": 25}
	],
	"nodes": [
		{x: 0, y: 0},
		{x: 50, y: 5},
		{x: 25, y: 50}
	]
};
