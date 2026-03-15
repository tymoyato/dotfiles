# Everforest Theme for Awesome WM

A beautiful green-based theme for Awesome Window Manager inspired by the [Everforest](https://github.com/sainnhe/everforest) color scheme. This theme aims to be warm and soft, designed to protect your eyes during long coding sessions.

## Color Scheme

This theme uses the Everforest Dark Medium Contrast variant:

### Background Colors
- **bg0**: `#2D353B` - Main background
- **bg1**: `#343F44` - Secondary background  
- **bg2**: `#3D484D` - Tertiary background
- **bg3**: `#475258` - Widget backgrounds
- **bg_green**: `#425047` - Green-tinted background for focus states

### Foreground Colors
- **fg**: `#D3C6AA` - Main foreground text
- **green**: `#A7C080` - Primary accent (green)
- **red**: `#E67E80` - Error/urgent states
- **orange**: `#E69875` - Warning states
- **yellow**: `#DBBC7F` - Notifications
- **blue**: `#7FBBB3` - Information
- **purple**: `#D699B6` - Special elements
- **aqua**: `#83C092` - Highlights

## Features

- 🌲 Forest-themed aesthetic with tree emoji widget
- 🎨 Consistent Everforest color scheme throughout all widgets
- 📱 Custom widget configurations for all system monitors
- 🖼️ Support for custom wallpapers
- 🎵 Music control widget with playerctl integration
- 🔆 Brightness control widget
- 🔊 Volume control with visual bar
- 🌡️ Temperature monitoring
- 💾 Memory and CPU usage displays
- 🔋 Battery status with visual indicators
- ⌨️ Keyboard layout switcher
- 🌐 Network speed monitor

## Installation

1. Copy the `everforest` theme directory to your Awesome themes folder:
   ```bash
   cp -r everforest ~/.config/awesome/themes/
   ```

2. In your `rc.lua`, set the theme:
   ```lua
   beautiful.init("~/.config/awesome/themes/everforest/theme.lua")
   ```

3. Add a suitable wallpaper to the `wallpapers/` directory and update the theme if needed.

## Wallpaper

The theme expects a wallpaper at `wallpapers/everforest.jpg`. You can:
- Add your own forest/nature themed wallpaper
- Download an Everforest-themed wallpaper from the community
- Update the `theme.wallpaper` path in `theme.lua` to point to your preferred image

## Widget Configuration

All widgets are configured with Everforest colors and can be found in the `widgets_config/` directory:

- `battery_widget.lua` - Battery status and charging indicator
- `brightness_widget.lua` - Screen brightness control
- `clock_widget.lua` - Date/time display with calendar popup
- `cpu_widget.lua` - CPU usage monitor
- `mem_widget.lua` - Memory usage display
- `music_widget.lua` - Music player controls
- `temp_widget.lua` - System temperature monitor
- `volume_widget.lua` - Audio volume control

## Dependencies

Make sure you have the following dependencies installed:
- `playerctl` - For music control widget
- `light` - For brightness control widget
- `alsa-utils` - For volume control
- `lain` - Awesome WM widget library

## Customization

You can customize the theme by modifying the color values in `theme.lua`. All colors follow the Everforest specification and can be adjusted to your preference while maintaining the overall aesthetic.

## Credits

- Color scheme inspired by [Everforest](https://github.com/sainnhe/everforest) by sainnhe
- Based on the existing CCCP and Kitay themes structure
- Created for Awesome Window Manager
