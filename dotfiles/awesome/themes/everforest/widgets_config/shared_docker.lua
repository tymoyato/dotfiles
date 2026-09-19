-- Shared Docker data module
-- Runs ONE combined poll every 20s.
-- All docker widgets subscribe here instead of spawning their own processes.
local gears = require("gears")
local awful = require("awful")

local M = {}
M._subscribers = {}
M.data = {
    available   = false,  -- docker daemon reachable
    containers  = {},     -- list of container tables
    stats       = {},     -- map name → { cpu, mem_mb, cpu_str, mem_used, mem_limit, mem_perc }
    total_cpu   = 0.0,
    total_mem   = 0.0,
}

local _stats_pending = false
local _ps_done    = false
local _stats_done = false

local function notify_all()
    for _, cb in ipairs(M._subscribers) do
        cb(M.data)
    end
end

local function try_finish()
    if _ps_done and _stats_done then
        _ps_done, _stats_done = false, false
        notify_all()
    end
end

-- Parse "256MiB" / "1.5GiB" / "512kB" → MiB float
local function to_mib(str)
    if not str then return 0 end
    local val, unit = str:match("^([%d%.]+)%s*([A-Za-z]+)$")
    val = tonumber(val) or 0
    if not unit then return val end
    unit = unit:lower()
    if unit == "gib" or unit == "gb"  then return val * 1024
    elseif unit == "mib" or unit == "mb"  then return val
    elseif unit == "kib" or unit == "kb"  then return val / 1024
    elseif unit == "b"                     then return val / (1024 * 1024)
    end
    return val
end

local function poll()
    _ps_done, _stats_done = false, false

    -- Query 1: container list with compose labels
    awful.spawn.easy_async_with_shell(
        "docker ps -a --format '{{.Names}}|{{.Status}}|{{.Label \"com.docker.compose.project\"}}|{{.Label \"com.docker.compose.service\"}}' 2>/dev/null",
        function(stdout, _, _, code)
            M.data.containers = {}
            M.data.available  = (code == 0)
            if code == 0 then
                for line in stdout:gmatch("[^\n]+") do
                    local name, status, proj, svc = line:match("^([^|]*)|([^|]*)|([^|]*)|(.*)$")
                    if name and name ~= "" then
                        local stat_lower = status:lower()
                        table.insert(M.data.containers, {
                            name      = name,
                            status    = status,
                            proj      = (proj ~= "" and proj or nil),
                            svc       = (svc  ~= "" and svc  or name),
                            running   = stat_lower:match("^up") ~= nil,
                            unhealthy = stat_lower:match("unhealthy") ~= nil,
                            healthy   = stat_lower:match("%(healthy%)") ~= nil,
                            starting  = stat_lower:match("%(starting%)") ~= nil,
                        })
                    end
                end
            end
            _ps_done = true
            try_finish()
        end
    )

    -- Query 2: resource stats (only for running containers)
    awful.spawn.easy_async_with_shell(
        "docker stats --no-stream --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}' 2>/dev/null",
        function(stdout, _, _, code)
            M.data.stats     = {}
            M.data.total_cpu = 0.0
            M.data.total_mem = 0.0
            if code == 0 then
                for line in stdout:gmatch("[^\n]+") do
                    local name, cpu_s, mem_s, mem_p = line:match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
                    if name then
                        local cpu_val = tonumber(cpu_s:match("([%d%.]+)")) or 0
                        local used, limit = mem_s:match("([%d%.%a]+)%s*/%s*([%d%.%a]+)")
                        local mem_mb = to_mib(used)
                        M.data.stats[name] = {
                            cpu       = cpu_val,
                            cpu_str   = cpu_s,
                            mem_used  = used  or "?",
                            mem_limit = limit or "?",
                            mem_perc  = mem_p,
                            mem_mb    = mem_mb,
                        }
                        M.data.total_cpu = M.data.total_cpu + cpu_val
                        M.data.total_mem = M.data.total_mem + mem_mb
                    end
                end
            end
            _stats_done = true
            try_finish()
        end
    )
end

-- Poll every 20 seconds. `docker stats` is a continuously-varying live
-- metric (like CPU%) with no discrete "changed" event, so this stays on a
-- timer regardless. Container start/stop/health, however, are discrete
-- events — `docker events` below reflects those immediately instead of
-- waiting up to 20s for the next tick.
gears.timer { timeout = 20, autostart = true, callback = poll }

-- Debounce: `docker compose up` starting several containers at once would
-- otherwise trigger a burst of redundant polls.
local events_debounce = nil
local function debounced_poll()
    if events_debounce then events_debounce:stop() end
    events_debounce = gears.timer.start_new(1, function()
        events_debounce = nil
        poll()
        return false
    end)
end

local function start_events()
    awful.spawn.with_line_callback(
        { "docker", "events", "--filter", "type=container", "--format", "{{.Action}}" },
        {
            stdout = function(_) debounced_poll() end,
            exit = function()
                -- docker daemon restart, socket hiccup, etc — reconnect.
                gears.timer.start_new(2, function()
                    start_events()
                    return false
                end)
            end,
        }
    )
end

-- Kill any events listener left over from a previous awesome session
-- (awesome.restart() re-execs in place and never reaps old children).
awful.spawn.easy_async(
    { "pkill", "-f", "docker events --filter type=container" },
    start_events
)

-- Initial poll
poll()

function M.subscribe(cb)
    table.insert(M._subscribers, cb)
end

-- Trigger an immediate re-poll (e.g. after docker action)
function M.refresh()
    poll()
end

return M
