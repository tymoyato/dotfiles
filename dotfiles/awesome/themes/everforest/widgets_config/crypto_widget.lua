-- Crypto prices (BTC + ETH in EUR)
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require("gears")
local lain = require("lain")
local markup = lain.util.markup

theme.widget_crypto = theme.dir .. "/icons/widgets/crypto.png"
theme.widget_eth    = theme.dir .. "/icons/widgets/eth.png"
local crypto_icon = wibox.widget.imagebox(theme.widget_crypto)
local eth_icon    = wibox.widget.imagebox(theme.widget_eth)
local btc_text    = wibox.widget.textbox()
local eth_text    = wibox.widget.textbox()

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
    function(_, stdout)
        local btc = stdout:match('"bitcoin"%s*:%s*{%s*"eur"%s*:%s*([%d%.]+)')
        local eth = stdout:match('"ethereum"%s*:%s*{%s*"eur"%s*:%s*([%d%.]+)')
        btc_text:set_markup(markup.font(theme.font,
            markup.fg.color(theme.fg_normal, " " .. (btc and format_price(btc) or "?") .. " ")))
        eth_text:set_markup(markup.font(theme.font,
            markup.fg.color(theme.fg_normal, " " .. (eth and format_price(eth) or "?") .. " ")))
    end
)

local crypto_widget = wibox.container.background(
    wibox.container.margin(
        wibox.widget({ crypto_icon, btc_text, eth_icon, eth_text, layout = wibox.layout.fixed.horizontal }),
        2, 2
    ),
    "#000000",
    gears.shape.octogon
)

return crypto_widget
