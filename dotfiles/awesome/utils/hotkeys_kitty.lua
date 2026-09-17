---------------------------------------------------------------------------
--- Kitty hotkeys for our hotkeys_popup_widget fork.
--
-- Only the kittens mapped in kitty.conf (kitty's own defaults are already
-- documented by kitty itself). Shown only while a kitty window is focused.
---------------------------------------------------------------------------

local hotkeys_widget = require("utils.hotkeys_popup_widget")

hotkeys_widget.add_group_rules("kitty", { rule = { class = "kitty" } })

hotkeys_widget.add_hotkeys({
	kitty = {
		{
			modifiers = { "Ctrl", "Shift" },
			keys = {
				f = "search scrollback buffer",
				g = "vim-like text selection/copy (kitty_grab)",
				z = "background opacity: full (solid)",
				o = "background opacity: restore default",
			},
		},
	},
})
