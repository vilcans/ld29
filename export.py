import json
from pprint import pprint
import bpy

def export(mesh_name, file_name):
    data = bpy.data.meshes['Grid.001']
    data.update(calc_tessface=True)

    nodes = []
    faces = []
        
    def screen_x(x):
        return int(x + 608 / 2 + .5)

    def screen_y(y):
        return int(-y + 906 / 2 + .5)

    def average(values):
        return sum(values) / len(values)

    def get_edge_key(node1, node2):
        if node1 < node2:
            return (node1, node2)
        else:
            return (node2, node1)

    for v in data.vertices:
        nodes.append({
            'x': screen_x(v.co.x),
            'y': screen_y(v.co.y)
        })

    edge_to_faces = {}

    for face_number, face in enumerate(data.tessfaces):
        print('face number', face_number)
        face_data = {
            'id': face_number,
            'x': screen_x(average([data.vertices[n].co.x for n in face.vertices])),
            'y': screen_y(average([data.vertices[n].co.y for n in face.vertices])),
            'nodes': list(face.vertices),
            'neighbors': [],
        }
        for n1, n2 in zip(face.vertices, list(face.vertices[1:]) + [face.vertices[0]]):
            edge_key = get_edge_key(n1, n2)
            if edge_key in edge_to_faces:
                edge_to_faces[edge_key].append(face_data)
            else:
                edge_to_faces[edge_key] = [face_data]
        faces.append(face_data)

    def set_neighbors():
        for edge_key, faces in edge_to_faces.items():
            print('edge key', edge_key)
            for face in faces:
                face['neighbors'] += [
                    neighbor['id'] for neighbor in faces if neighbor != face
                ]
                print('..face', face)

    set_neighbors()

    result = {
        'nodes': nodes,
        'faces': faces,
        'edges': list(list(x) for x in edge_to_faces.keys()),
    }
    pprint(result)

    with open(file_name, 'w') as out:
        out.write('window.graphData = window.graphData || {};\n')
        out.write('window.graphData[\'layer1\'] = ')
        json.dump(result, out, sort_keys=True)
        out.write(';\n')

export('Grid.001', '/home/vilcans/proj/ld29/app/scripts/layer1.js')
