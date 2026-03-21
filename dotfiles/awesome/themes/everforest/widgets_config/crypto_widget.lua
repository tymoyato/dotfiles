-- Crypto prices (BTC + ETH in EUR)
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require("gears")
local lain = require("lain")
local markup = lain.util.markup

local crypto_text = wibox.widget.textbox()

local function format_price(price)
    local n = tonumber(price)
    if not n then return "?" end
    if n >= 1000 then
        return string.format("%.1fk", n / 1000)
    end
    return string.format("%d", math.floor(n))
end

watch(
    "curl -s --max-time 10 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=eur'",
    300,
    function(widget, stdout)
        local btc = stdout:match('"bitcoin"%s*:%s*{%s*"eur"%s*:%s*([%d%.]+)')
        local eth = stdout:match('"ethereum"%s*:%s*{%s*"eur"%s*:%s*([%d%.]+)')
        local text
        if btc and eth then
            text = markup.fg.color(theme.fg_normal,
                " ₿" .. format_price(btc) .. "  Ξ" .. format_price(eth) .. " ")
        else
            text = markup.fg.color(theme.fg_normal, " ₿?  Ξ? ")
        end
        widget:set_markup(markup.font(theme.font, text))
    end,
    crypto_text
)

local crypto_widget = wibox.container.background(
    wibox.container.margin(crypto_text, 2, 2),
    "#425047",
    gears.shape.rounded_rect
)

return crypto_widget
