# Comment Stripper Plugin for Godot 4.x

A Godot export editor plugin that automatically strips comments from GDScript files during export.

![Godot Comment Stripper Icon](./icon.svg)

## Features

- **Automatic Comment Stripping**: Removes all comments from `.gd` files during export
- **Release-Only Operation**: Only strips comments for release builds, preserves comments in debug builds
- **Recursive Directory Scanning**: Processes all `.gd` files in the `scripts/` directory and subdirectories

## Installation & Usage

1. Copy the `comment_stripper` folder to your project's `addons/` directory
2. Enable the plugin in Project Settings → Plugins
3. The plugin will automatically activate for all release exports
4. The plugin outputs all actions to the console for monitoring
5. The plugin will exclude itself from the export

### Supported File Structure

The plugin processes all `.gd` files in your `scripts/` directory:

## Technical Details

- **File Processing**: Recursively scans directories and modifies `.gd` files in place
- **Comment Detection**: Removes single-line comments (`# comment`), mult-line comments and empty lines

## Requirements

- Godot 4.x

## License

MIT License - see LICENSE file for details.

## Disclaimer

The author is not liable for any damages or losses resulting from the use of this plugin.

## Author

Matt Hall
@KLICKTOCK