import bpy

data = bpy.data.meshes['Grid']

# Maps vertex to index.
# Used for finding identical vertices and reuse their indices.
indexed_vertices = {}

for face_number, face in enumerate(data.tessfaces):
    print(face_number, face)
