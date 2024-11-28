@tool
extends NavigationRegion3D

@export var generate: bool = false:
	set(value):
		_on_generate()

var _source_nodes: Array[MeshInstance3D] = []
var _final_mesh: ArrayMesh


func _on_generate():
	# cleanup
	_source_nodes.clear()
	_final_mesh = ArrayMesh.new()
	
	if !navigation_mesh:
		printerr("E: no navigation_mesh found")
		return
	print("I: Generating navigation mesh")
	
	_rec_find_mesh(self)
	_generate()
	print("I: Finished")


func _rec_find_mesh(node: Node):
	if node is MeshInstance3D:
		var mesh: Mesh = node.mesh
		if mesh is ArrayMesh:
			_source_nodes.append(node)
	for child in node.get_children():
		_rec_find_mesh(child)


func _generate():
	# extract surfaces and transform vertex
	for node: MeshInstance3D in _source_nodes:
		if node.mesh is ArrayMesh:
			_compile_mesh(node.mesh, node.global_transform)
			
	print("I: final_mesh surfaces = %s" % _final_mesh.get_surface_count())
	
	# set nav mesh
	var navmesh = navigation_mesh
	navmesh.create_from_mesh(_final_mesh)
	set_navigation_mesh(null)
	set_navigation_mesh(navmesh)


func _compile_mesh(array_mesh: ArrayMesh, trans: Transform3D):
	var aux_mesh = ArrayMesh.new()
	var copy_mesh = ArrayMesh.new()
	
	# extract surfaces
	for i in array_mesh.get_surface_count():
		aux_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array_mesh.surface_get_arrays(i))
	
	var origin_offset = trans.origin - global_position
	var scale_offset = trans.basis.get_scale()
	var quat_offset = trans.basis.get_rotation_quaternion().inverse()
	
	for k in aux_mesh.get_surface_count():
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(aux_mesh, k)
		
		# offset each vertex
		for i in range(mdt.get_vertex_count()):
			mdt.set_vertex(i, (mdt.get_vertex(i) * scale_offset) * quat_offset + origin_offset)
		
		copy_mesh.clear_surfaces()
		mdt.commit_to_surface(copy_mesh)
		
		# compile
		for i in copy_mesh.get_surface_count():
			_final_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, copy_mesh.surface_get_arrays(i))
