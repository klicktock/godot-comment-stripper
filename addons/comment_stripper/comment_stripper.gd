@tool
extends EditorPlugin

# Comment Stripper Plugin

var export_plugin: CommentStripperExportPlugin

func _enter_tree():
	print("Comment Stripper Plugin: Loaded")
	export_plugin = CommentStripperExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree():
	print("Comment Stripper Plugin: Unloaded")
	if export_plugin:
		remove_export_plugin(export_plugin)
		export_plugin = null

# EditorExportPlugin for comment stripping
class CommentStripperExportPlugin extends EditorExportPlugin:
	var original_scripts: Dictionary = {}
	
	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		# Only strip comments on RELEASE builds (not debug builds)
		if is_debug:
			return
		
		print("Comment Stripper: Stripping comments for release build")
		_strip_comments_from_scripts()
	
	func _export_end() -> void:
		print("Comment Stripper: Restoring comments")
		_restore_comments_from_scripts()
	
	func _strip_comments_from_scripts():
		"""Strip comments from all .gd scripts before export."""
		var scripts_dir = "res://scripts"
		original_scripts.clear()
		
		_recursive_strip_comments(scripts_dir)
		print("Comment Stripper: Stripped comments from scripts")
	
	func _recursive_strip_comments(dir_path: String):
		"""Recursively strip comments from all .gd files in directory and subdirectories."""
		var dir = DirAccess.open(dir_path)
		
		if not dir:
			return
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = dir_path.path_join(file_name)
			
			if dir.current_is_dir():
				# Recursively process subdirectories
				_recursive_strip_comments(full_path)
			elif file_name.ends_with(".gd"):
				# Process .gd files
				_strip_comments_from_file(full_path)
			
			file_name = dir.get_next()
	
	func _strip_comments_from_file(file_path: String):
		"""Strip comments from a single .gd file."""
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			return
		
		# Store original content for restoration
		original_scripts[file_path] = file.get_as_text()
		file.close()
		
		# Read and process content
		file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		# Strip comments
		var stripped_content = _strip_comments(content)
		
		# Write stripped content back
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(stripped_content)
			file.close()
			print("Comment Stripper: Stripped comments from ", file_path)
	
	func _strip_comments(content: String) -> String:
		"""Remove comments from GDScript content."""
		var lines = content.split("\n")
		var stripped_lines: Array[String] = []
		
		for line in lines:
			# Remove single-line comments (# ...)
			var comment_pos = line.find("#")
			if comment_pos >= 0:
				line = line.substr(0, comment_pos)
			
			# Remove empty lines (optional - you can comment this out)
			if line.strip_edges() != "":
				stripped_lines.append(line.strip_edges())
		
		return "\n".join(stripped_lines)
	
	func _restore_comments_from_scripts():
		"""Restore original script content after export."""
		for file_path in original_scripts:
			var file = FileAccess.open(file_path, FileAccess.WRITE)
			if file:
				file.store_string(original_scripts[file_path])
				file.close()
				print("Comment Stripper: Restored comments to ", file_path)
		
		original_scripts.clear()
		print("Comment Stripper: All comments restored")
