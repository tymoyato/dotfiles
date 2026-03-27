-- RSS feed widget
-- Left-click:  show/hide articles popup
-- Right-click: mark all as read
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")

-- ── Feed list — edit this to add/remove feeds ──────────────────────
local FEEDS = {
    "https://feeds.bbci.co.uk/news/rss.xml",
    "https://archlinux.org/feeds/news/",
    "https://www.reddit.com/r/linux/.rss",
    "https://rubyonrails.org/blog/feed/atom.xml",
}

-- ── Config ─────────────────────────────────────────────────────────
local REFRESH_INTERVAL = 30 * 60   -- 30 minutes
local MAX_PER_FEED     = 10
local READ_FILE        = os.getenv("HOME") .. "/.config/awesome/rss_read.txt"

-- ── Everforest colors ──────────────────────────────────────────────
local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local bg_read   = "#2D353B"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_grey   = "#7A8478"
local fg_yellow = "#DBBC7F"

-- ── State ──────────────────────────────────────────────────────────
local articles  = {}   -- list of { title, url, feed, date, read }
local read_urls = {}   -- set of read URLs
local popup     = nil

-- ── Persistence ────────────────────────────────────────────────────
local function load_read()
    read_urls = {}
    local f = io.open(READ_FILE, "r")
    if not f then return end
    for line in f:lines() do
        read_urls[line] = true
    end
    f:close()
end

local function save_read()
    local f = io.open(READ_FILE, "w")
    if not f then return end
    for url in pairs(read_urls) do
        f:write(url .. "\n")
    end
    f:close()
end

load_read()

-- ── Label ──────────────────────────────────────────────────────────
local rss_label = wibox.widget.textbox()

local function unread_count()
    local n = 0
    for _, a in ipairs(articles) do
        if not a.read then n = n + 1 end
    end
    return n
end

local function refresh_label()
    local count = unread_count()
    rss_label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> <span font="Symbols Nerd Font Mono 10" color="#E69875">\u{F09E}</span> %d </span>',
        fg_color, count
    ))
end
refresh_label()

local rss_widget = wibox.container.background(
    wibox.container.margin(rss_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- ── Python script written to disk for reliable execution ───────────
local SCRIPT_FILE = os.getenv("HOME") .. "/.config/awesome/rss_fetch.py"

local python_code = [=[
import sys, json, urllib.request, xml.etree.ElementTree as ET

feeds   = json.loads(sys.argv[1])
max_per = int(sys.argv[2])
results = []

for url in feeds:
    try:
        req  = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        data = urllib.request.urlopen(req, timeout=10).read()
        root = ET.fromstring(data)
        ns   = {"atom": "http://www.w3.org/2005/Atom"}

        items = root.findall(".//item")
        if items:
            feed_name = root.findtext(".//channel/title") or url
            for item in items[:max_per]:
                title = item.findtext("title") or ""
                link  = item.findtext("link")  or ""
                date  = item.findtext("pubDate") or ""
                results.append({"title": title.strip(), "url": link.strip(),
                                 "feed": feed_name.strip(), "date": date.strip()[:16]})
        else:
            feed_name = root.findtext("atom:title", ns) or url
            for entry in root.findall("atom:entry", ns)[:max_per]:
                title = entry.findtext("atom:title", ns) or ""
                lel   = entry.find("atom:link", ns)
                link  = lel.get("href") if lel is not None else ""
                date  = entry.findtext("atom:updated", ns) or ""
                results.append({"title": title.strip(), "url": link.strip(),
                                 "feed": feed_name.strip(), "date": date.strip()[:16]})
    except Exception as e:
        sys.stderr.write(str(e) + "\n")

print(json.dumps(results, separators=(',', ':')))
]=]

do
    local f = io.open(SCRIPT_FILE, "w")
    if f then f:write(python_code) f:close() end
end

-- ── Fetch feeds ────────────────────────────────────────────────────
local function fetch_feeds()
    local feed_json = "["
    for i, f in ipairs(FEEDS) do
        feed_json = feed_json .. string.format('"%s"', f)
        if i < #FEEDS then feed_json = feed_json .. "," end
    end
    feed_json = feed_json .. "]"

    local cmd = string.format("python3 %s '%s' %d 2>/dev/null",
        SCRIPT_FILE, feed_json, MAX_PER_FEED)

    awful.spawn.easy_async_with_shell(cmd, function(stdout)
        stdout = stdout:match("^%s*(.-)%s*$")
        if stdout == "" or stdout:sub(1,1) ~= "[" then return end
        articles = {}
        for obj in stdout:gmatch("%b{}") do
            local title = obj:match('"title":"(.-)"') or ""
            local url   = obj:match('"url":"(.-)"')   or ""
            local feed  = obj:match('"feed":"(.-)"')  or ""
            local date  = obj:match('"date":"(.-)"')  or ""
            -- unescape basic JSON escapes
            title = title:gsub('\\"', '"'):gsub("\\n", " "):gsub("\\\\", "\\")
            feed  = feed:gsub('\\"', '"'):gsub("\\\\", "\\")
            if url ~= "" then
                table.insert(articles, {
                    title = title,
                    url   = url,
                    feed  = feed,
                    date  = date,
                    read  = read_urls[url] or false,
                })
            end
        end
        refresh_label()
    end)
end

fetch_feeds()
gears.timer {
    timeout   = REFRESH_INTERVAL,
    autostart = true,
    callback  = fetch_feeds,
}

-- ── Popup ──────────────────────────────────────────────────────────
local VISIBLE_ROWS = 15
local scroll_offset = 0
local list_layout   = nil

local function close_popup()
    if popup then
        popup.visible = false
        popup = nil
    end
end

local function make_article_row(a)
    local row = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s">%s</span>'
                    .. '<span font="Meslo LGS Regular 10" color="%s">  %s</span>',
                    a.read and fg_grey or fg_color,
                    gears.string.xml_escape(a.title ~= "" and a.title or "(no title)"),
                    fg_grey,
                    gears.string.xml_escape(a.date)
                ),
                wrap   = "word_char",
                widget = wibox.widget.textbox,
            },
            6, 6, 3, 3
        ),
        a.read and bg_read or bg_row
    )
    row:connect_signal("mouse::enter", function() row.bg = "#4a5e53" end)
    row:connect_signal("mouse::leave", function() row.bg = a.read and bg_read or bg_row end)
    row:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 and a.url ~= "" then
            a.read         = true
            read_urls[a.url] = true
            save_read()
            refresh_label()
            awful.spawn("xdg-open " .. a.url)
            close_popup()
        end
    end)
    return row
end

local function fill_list()
    list_layout:reset()
    local total = #articles
    local last  = math.min(scroll_offset + VISIBLE_ROWS, total)
    -- group by feed
    local current_feed = nil
    for i = scroll_offset + 1, last do
        local a = articles[i]
        if a.feed ~= current_feed then
            current_feed = a.feed
            list_layout:add(wibox.widget {
                {
                    markup = string.format(
                        '<span font="Meslo LGS Regular 10" color="%s"><b> %s </b></span>',
                        fg_green, gears.string.xml_escape(a.feed)
                    ),
                    widget = wibox.widget.textbox,
                },
                top = 3, bottom = 1, left = 4, right = 4,
                widget = wibox.container.margin,
            })
        end
        list_layout:add(make_article_row(a))
    end
    if total > VISIBLE_ROWS then
        list_layout:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> ↕ %d–%d of %d </span>',
                    fg_grey, scroll_offset + 1, last, total
                ),
                widget = wibox.widget.textbox,
            },
            top = 2, bottom = 2, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    end
end

local function show_popup()
    close_popup()
    scroll_offset = 0
    list_layout   = wibox.layout.fixed.vertical()

    local header = wibox.layout.fixed.vertical()
    header:add(wibox.widget {
        {
            markup = string.format(
                '<span font="Meslo LGS Regular 10" color="%s"><b> <span font="Symbols Nerd Font Mono 10" color="#E69875">\u{F09E}</span> RSS — %d unread </b></span>',
                fg_green, unread_count()
            ),
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    header:add(wibox.widget {
        color = fg_grey, forced_height = 1,
        widget = wibox.widget.separator,
    })

    if #articles == 0 then
        list_layout:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> No articles </span>',
                    fg_grey
                ),
                widget = wibox.widget.textbox,
            },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        fill_list()
    end

    local root = wibox.layout.fixed.vertical()
    root:add(header)
    root:add(list_layout)

    popup = awful.popup {
        widget = {
            root,
            bg     = bg_popup,
            widget = wibox.container.background,
        },
        placement = function(w)
            awful.placement.top_right(w, {
                honor_workarea = true,
                margins        = { top = 18, right = 0 },
            })
        end,
        shape         = gears.shape.rounded_rect,
        border_width  = 2,
        border_color  = fg_green,
        ontop         = true,
        visible       = true,
        minimum_width = 340,
        maximum_width = 560,
    }

    popup:connect_signal("mouse::leave", function() close_popup() end)
    popup:buttons(gears.table.join(
        awful.button({}, 5, function()
            if scroll_offset + VISIBLE_ROWS < #articles then
                scroll_offset = scroll_offset + 3
                fill_list()
            end
        end),
        awful.button({}, 4, function()
            if scroll_offset > 0 then
                scroll_offset = math.max(0, scroll_offset - 3)
                fill_list()
            end
        end)
    ))
end

-- ── Buttons ────────────────────────────────────────────────────────
rss_widget:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function()
        for _, a in ipairs(articles) do
            a.read           = true
            read_urls[a.url] = true
        end
        save_read()
        refresh_label()
        close_popup()
    end)
))

return rss_widget
