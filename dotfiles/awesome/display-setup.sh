#!/bin/sh
# Set every connected output to its preferred resolution at the highest
# refresh rate that resolution supports (e.g. 1920x1080 @ 239.76 instead of 60).
xrandr --query | awk '
	/ disconnected/ { out = ""; next }
	/ connected/    { out = $1; next }
	out && /\+/ {
		best = ""
		for (i = 2; i <= NF; i++) { r = $i; gsub(/[*+]/, "", r); if (r != "" && r + 0 > best + 0) best = r }
		printf "xrandr --output %s --mode %s --rate %s\n", out, $1, best
		out = ""
	}' | sh
