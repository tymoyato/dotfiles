# CCCP Theme for AwesomeWM

A CCCP-inspired theme for Awesome Window Manager based on the kitay theme.

## Features

- **CCCP Color Palette**: Features reds, golds, and dark colors inspired by CCCP aesthetics
- **Custom Widget Colors**: All widgets are themed with CCCP colors
- **Complete Theme**: Includes all necessary files and configurations

## Color Scheme

- **Primary Red**: `#DC143C` (Crimson red)
- **Dark Red**: `#8B0000` (Dark red)
- **Gold**: `#FFD700` (Gold)
- **Orange Red**: `#FF4500` (Orange red)
- **Forest Green**: `#228B22` (Forest green)
- **Royal Blue**: `#4169E1` (Royal blue)
- **Dark Background**: `#1a1a1a` (Dark gray)

## Usage

To use the CCCP theme, add the following line to your `rc.lua`:

```lua
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/cccp/theme.lua")
```

## Widgets

All widgets have been themed with CCCP colors:

- **Clock**: Crimson red background with gold text
- **Battery**: Crimson red background with gold progress bar
- **CPU**: Forest green background
- **Memory**: Orange red background
- **Temperature**: Dark goldenrod background
- **Volume**: Royal blue background
- **Brightness**: Blue violet background
- **Music**: Deep pink background with gold text
- **Network Speed**: Crimson red background

## Files Structure

```
themes/cccp/
├── theme.lua                 # Main theme file
├── widgets_config/           # CCCP-themed widget configurations
│   ├── battery_widget.lua
│   ├── brightness_widget.lua
│   ├── clock_widget.lua
│   ├── cpu_widget.lua
│   ├── mem_widget.lua
│   ├── music_widget.lua
│   ├── temp_widget.lua
│   └── volume_widget.lua
├── icons/                    # Theme icons (copied from kitay)
├── wallpapers/              # Theme wallpapers
└── README.md                # This file
```

## Customization

You can customize the colors by editing the color variables in `theme.lua`:

```lua
-- CCCP colors
theme.green = "#228B22"      -- Forest green
theme.red = "#DC143C"        -- Crimson red
theme.yellow = "#FFD700"     -- Gold
theme.blue = "#4169E1"       -- Royal blue
theme.darkred = "#8B0000"    -- Dark red
theme.darkgreen = "#006400"  -- Dark green
theme.darkyellow = "#B8860B" -- Dark goldenrod
theme.gray = "#696969"       -- Dim gray
theme.lightgrey = "#D3D3D3"  -- Light gray
theme.violet = "#8A2BE2"     -- Blue violet
theme.pink = "#FF1493"       -- Deep pink
```

## Requirements

- AwesomeWM
- All the same dependencies as the original kitay theme
- The `light` program for brightness control
- `playerctl` for music widget functionality

## Credits

Based on the kitay theme, adapted with CCCP-inspired colors and aesthetics. 