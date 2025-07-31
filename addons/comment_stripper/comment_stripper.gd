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
	var is_debug_build: bool = false

	func _get_name() -> String:
		return "Comment Stripper"
	
	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		# Store debug state for use in _export_file
		is_debug_build = is_debug
		
		if not is_debug_build:
			print("Comment Stripper: Will strip comments for release build")
	
	func _export_file(path: String, type: String, features: PackedStringArray) -> void:
		# Skip the plugin itself - don't include it in the export
		if path.begins_with("res://addons/comment_stripper/"):
			print("Comment Stripper: Skipping plugin file ", path)
			skip()
			return
			
		# Skip comment stripping for debug builds
		if is_debug_build:
			return
			
		# Only process .gd files
		if not path.ends_with(".gd"):
			return
		
		# Only process files in the scripts directory
		if not path.begins_with("res://scripts/"):
			return
		
		# Read the original file content
		var file = FileAccess.open(path, FileAccess.READ)
		if not file:
			return
		
		var content = file.get_as_text()
		file.close()
		
		# Strip comments from the content
		var stripped_content = _strip_comments(content)
		
		# Add the stripped content to the export
		add_file(path, stripped_content.to_utf8_buffer(), false)
		
		print("Comment Stripper: Stripped comments from ", path)
	
	func _strip_comments(content: String) -> String:
		# Remove comments from GDScript content.
		var lines = content.split("\n")
		var stripped_lines: Array[String] = []
		var in_multiline_comment = false
		
		for line in lines:
			var stripped_line = line
			
			# Handle multi-line comments (""")
			if not in_multiline_comment:
				var start_pos = stripped_line.find('"""')
				if start_pos >= 0:
					var end_pos = stripped_line.find('"""', start_pos + 3)
					if end_pos >= 0:
						# Comment ends on same line
						stripped_line = stripped_line.substr(0, start_pos) + stripped_line.substr(end_pos + 3)
					else:
						# Comment continues to next line
						stripped_line = stripped_line.substr(0, start_pos)
						in_multiline_comment = true
			else:
				var end_pos = stripped_line.find('"""')
				if end_pos >= 0:
					# Comment ends on this line
					stripped_line = stripped_line.substr(end_pos + 3)
					in_multiline_comment = false
				else:
					# Comment continues, skip this line entirely
					stripped_line = ""
			
			# Only process single-line comments if not in multi-line comment
			if not in_multiline_comment and stripped_line != "":
				# Find # but ignore if it's inside a string
				var comment_pos = -1
				var in_string = false
				var i = 0
				
				while i < stripped_line.length():
					var char = stripped_line[i]
					if char == '"' and (i == 0 or stripped_line[i - 1] != '\\'):
						in_string = !in_string
					elif char == '#' and not in_string:
						comment_pos = i
						break
					i += 1
				
				if comment_pos >= 0:
					stripped_line = stripped_line.substr(0, comment_pos)
			
			# Remove empty lines
			if stripped_line.strip_edges() != "":
				stripped_lines.append(stripped_line.strip_edges())
		
		return "\n".join(stripped_lines)
