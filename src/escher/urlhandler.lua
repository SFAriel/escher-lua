-- Escher URL Handler library
-- based on neturl.lua (Bertrand Mansion, 2011-2013; License MIT)
--
-- @module urlhandler
-- @alias M

local M = {}

local function decodeHexString(str)
  return string.char(tonumber(str, 16))
end

local function decode(str)
  return str:gsub("+", " "):gsub("%%(%x%x)", decodeHexString)
end

local function encodeAsHexString(char)
  return string.format("%%%02x", string.byte(char)):upper()
end

local function encode(str)
  return str:gsub("([^A-Za-z0-9%_%.%-%~])", encodeAsHexString)
end

function M.parse(url)
  url = tostring(url or "")

  local comp = {}

  M.setQuery(comp, "")

  url = url:gsub("%?(.*)", function(v)
    M.setQuery(comp, v)
    return ""
  end)

  comp.path = url

  return setmetatable(comp, {
    __index = M,
    __tostring = M.build
  })
end

function M.buildQuery(queryParts)
  local query = {}

  for _, queryPart in pairs(queryParts) do
    local name = encode(queryPart[1])
    local value = encode(queryPart[2])

    table.insert(query, string.format("%s=%s", name, value))
  end

  table.sort(query)

  return table.concat(query, "&")
end

function M.parseQuery(str)
  local values = {}

  for queryPartAsString in str:gmatch("[^&]+") do
    local key, val = queryPartAsString:match("([^=]*)=?(.*)")

    key = decode(key)
    key = key:gsub("=+.*$", "")
    val = val:gsub("^=+", "")

    table.insert(values, { key, decode(val) })
  end

  setmetatable(values, { __tostring = M.buildQuery })

  return values
end

function M:setQuery(query)
  self.queryParts = M.parseQuery(query)
  self.query = M.buildQuery(self.queryParts)

  return query
end

local function absolutePath(path)
  path = path:gsub("([^/]*%./)", function(str)
    if str ~= "./" then return str else return "" end
  end)

  local reduced
  while reduced ~= path do
    reduced = path
    path = reduced:gsub("([^/]*/%.%./)", function(str)
      if str ~= "../../" then return "" else return str end
    end)
  end

  path = path:gsub("([^/]*/%.%.?)$", function(str)
    if str ~= "../.." then return "" else return str end
  end)

  local reduced
  while reduced ~= path do
    reduced = path
    path = reduced:gsub("^/?%.%./", "")
  end

  return "/" .. path
end

function M:normalize()
  self.path = absolutePath(self.path):gsub("//+", "/")

  return self
end

return M
