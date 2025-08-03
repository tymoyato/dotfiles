local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

local package_log_widget = {}

-- Path to the package log file
local log_file = os.getenv("HOME") .. "/.Kitay-Gorod/linux/package_updates.log"

-- Loading animation - color change
local is_loading = false
local loading_timer = nil

-- Function to start loading animation
local function start_loading_animation(widget)
    is_loading = true
    
    -- Immediately show first frame with white color
    widget:set_markup('<span color="#FFFFFF">📦</span>')
    
    loading_timer = gears.timer({
        timeout = 0.5, -- Change every 500ms
        call_now = false,
        autostart = true,
        callback = function()
            if is_loading then
                -- Toggle between white and purple colors
                if widget:get_markup():find("#FFFFFF") then
                    widget:set_markup('<span color="#6c5ce7">📦</span>')
                else
                    widget:set_markup('<span color="#FFFFFF">📦</span>')
                end
            end
        end
    })
end

-- Function to stop loading animation
local function stop_loading_animation(widget)
    is_loading = false
    if loading_timer then
        loading_timer:stop()
        loading_timer = nil
    end
    widget:set_text("📦") -- Restore original icon
end

-- Function to strip ANSI color codes and format text
local function strip_colors_and_format(text)
    -- Remove ANSI color codes
    text = text:gsub("\27%[%d+;?%d*;?%d*;?%d*;?%d*m", "")
    -- Remove common shell symbols and replace with text
    text = text:gsub("ℹ", "INFO:")
    text = text:gsub("✓", "✓")
    text = text:gsub("⚠", "⚠")
    text = text:gsub("✗", "✗")
    text = text:gsub("📋", "CHANGELOG:")
    text = text:gsub("🔍", "DETAILED:")
    text = text:gsub("⚠️", "WARNING:")
    return text
end

-- Function to read the last N lines from the log file
local function read_last_lines(file_path, num_lines)
    local lines = {}
    local file = io.open(file_path, "r")
    if not file then
        return {"Log file not found"}
    end
    
    for line in file:lines() do
        -- Strip colors and format the line
        local clean_line = strip_colors_and_format(line)
        table.insert(lines, clean_line)
        if #lines > num_lines then
            table.remove(lines, 1)
        end
    end
    file:close()
    
    if #lines == 0 then
        return {"No package updates logged"}
    end
    
    return lines
end

-- Function to show package log notification
local function show_package_log()
    local lines = read_last_lines(log_file, 20)
    local content = table.concat(lines, "\n")
    
    naughty.notify({
        title = "📦 Package Updates Log",
        text = content,
        timeout = 15, -- Auto-dismiss after 15 seconds
        width = 700,
        height = 500,
        position = "top_right",
        fg = "#ffffff", -- White text for kitay theme
        bg = "#000000", -- Black background for kitay theme
        border_color = "#6c5ce7", -- Purple border for kitay theme
        border_width = 2,
        dismiss_on_click = true, -- Dismiss when clicked
        font = "Meslo LGS Regular 10", -- Use monospace font for better formatting
    })
end

-- Create the widget
local widget_text = wibox.widget.textbox("📦")
widget_text.font = "Meslo LGS Regular 10"

-- Add click events using buttons method (like other widgets)
widget_text:buttons(awful.util.table.join(
    awful.button({}, 1, function() -- Left click
        -- Create a persistent notification
        local progress_notification = naughty.notify({
            title = "📦 Package Check",
            text = "Checking for package updates...",
            timeout = 0, -- No timeout - stays visible
            position = "top_right",
            fg = "#FFD700",
            bg = "#1a1a1a",
            border_color = "#DC143C",
            border_width = 2,
        })
        
        -- Run package checker script with force flag to bypass daily limit
        awful.spawn.easy_async_with_shell("~/.Kitay-Gorod/dotfiles/awesome/utils/package-checker.sh --force", function(stdout, stderr, exitreason, exitcode)
            -- Dismiss the progress notification
            naughty.destroy(progress_notification)
            
            -- Show the log
            show_package_log()
        end)
    end),
    awful.button({}, 3, function() -- Right click
        show_package_log()
    end)
))

package_log_widget.widget = widget_text

return package_log_widget 