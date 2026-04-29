local template = {}

--[[
`loadstring` was deprecated since 5.2, use `load` instead
(see: https://www.lua.org/manual/5.2/manual.html#8.2)
]]--
local loadstring = loadstring or function(str, chkn)
  return load(str, chkn or str, 't')
end

function template.escape(data)
  return tostring(data == nil and "" or data):gsub("[\">/<'&]", {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["/"] = "&#47;"
  })
end

function template.print(data, args, callback)
  local callback = callback or print
  local function exec(data)
    if type(data) == "function" then
      local env = args or {}
      setmetatable(env, { __index = _G })
      if _ENV then -- Lua 5.2+
        local wrapper, err = load([[
          return function(_ENV, exec)
            local f = ...
            f(exec)
          end
        ]], "wrapper", "t", env)
        if not wrapper then
          error(err)
        end
        wrapper()(env, exec, data)
      else
        setfenv(data, env)
        data(exec)
      end
    else
      callback(tostring(data == nil and "" or data))
    end
  end
  exec(data)
end

function template.parse(data, minify)
  local str = 
    "return function(_)" .. 
      "function __(...)" ..
        "_(require('template').escape(...))" ..
      "end " ..
      "_[=[" ..
      data:
        gsub("[][]=[][]", ']=]_"%1"_[=['):
        gsub("<%%=", "]=]_("):
        gsub("<%%", "]=]__("):
        gsub("%%>", ")_[=["):
        gsub("<%?", "]=] "):
        gsub("%?>", " _[=[") ..
      "]=] " ..
    "end"
  if minify then
    str = str:
      gsub("^[ %s]*", ""):
      gsub("[ %s]*$", ""):
      gsub("%s+", " ")
  end
  return str
end

function template.compile(...)
  local f, err = loadstring(template.parse(...))
  if err then
    error(err)
  end
  return f()
end

function template.render(data, args)
  local parts = {}
  local i = 0

  template.print(data, args, function(p)
    i = i + 1
    parts[i] = p
  end)

  return table.concat(parts)
end

return template
