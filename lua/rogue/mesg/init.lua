---@type { JAPAN?: boolean, English?: boolean, [integer]: string }
local M = {}
---@type Path
local Path = require "plenary.path"

---@param fname string
---@return table<integer, string>|nil
local function read_mesg_file(fname)
  local mesg_file = io.open(fname, "r")
  if not mesg_file then
    return nil
  end
  ---@type table<integer, string>
  local mesg = {}
  for line in mesg_file:lines() do
    local num, msg = line:match '^(%d+)%s*"([^"]*)"'
    if num then
      num = tonumber(num)
      if not mesg[num] then
        mesg[num] = msg
      end
    end
  end
  mesg_file:close()
  return mesg
end

---@return table<integer, string>|nil
local function read_mesg()
  ---@type table<integer, string>
  local mesg = {}
  local file_dir = Path.new(debug.getinfo(1, "S").source:sub(2)):parent()
  local mesg_fname = vim.g["rogue#message"]
  if type(mesg_fname) == "string" and mesg_fname ~= "" then
    mesg = vim.tbl_deep_extend("force", mesg, read_mesg_file(mesg_fname))
  end

  local japanese = vim.g["rogue#japanese"]
  ---@type string
  local lang = vim.v.lang
  if type(japanese) == "number" then
    M.JAPAN = japanese ~= 0
  elseif lang:match "ja" then
    M.JAPAN = true
  else
    M.JAPAN = false
  end
  local default_f = M.JAPAN and "mesg" or "mesg_E"

  local ret = read_mesg_file(file_dir:joinpath(default_f):expand())
  if not ret then
    return nil
  end
  mesg = vim.tbl_deep_extend("force", mesg, ret)

  if not M.JAPAN and mesg[1]:find "English" then
    M.English = true
  end

  return mesg
end

M = vim.tbl_deep_extend("force", M, read_mesg())

return M
