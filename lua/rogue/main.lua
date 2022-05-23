local original_global_data = {}
for k, v in pairs(_G) do
  original_global_data[k] = tostring(v)
end

Rogue = {}
local g = Rogue -- alias
local util = require "rogue.util"

g.version = "1.0.2"

-- Checks added global data is Rogue only
local function check_global()
  local added_global_data = {}
  for k, v in pairs(_G) do
    if not original_global_data[k] then
      added_global_data[k] = tostring(v)
    end
  end
  g.p("original_global_data", true)
  g.p("added_global_data", true)
end

local function init_dirs()
  g.home_dir = os.getenv "HOME"
  if not g.home_dir then
    g.home_dir = os.getenv "USERPROFILE"
    if not g.home_dir then
      g.home_dir = "."
    end
  end
  g.home_dir = g.home_dir:gsub("\\", "/")

  g.game_dir = vim.g["rogue#directory"]
  if type(g.game_dir) ~= "string" or g.game_dir == "" then
    g.game_dir = g.home_dir
  else
    g.game_dir = g.game_dir:gsub("\\", "/")
    g.game_dir = g.game_dir:gsub("~", g.home_dir)
    local exists = vim.fn.isdirectory(g.game_dir)
    if exists == 0 then
      vim.fn.mkdir(g.game_dir, "p")
    end
  end

  if string.char(g.home_dir:byte(#g.home_dir)) ~= "/" then
    g.home_dir = g.home_dir .. "/"
  end
  if string.char(g.game_dir:byte(#g.game_dir)) ~= "/" then
    g.game_dir = g.game_dir .. "/"
  end
end

g.mesg = {}
g.JAPAN = true

local function read_mesg_file(fname)
  local mesg_file = io.open(fname, "r")
  if not mesg_file then
    return false
  end
  for line in mesg_file:lines() do
    local num, msg = line:match '^(%d+)%s*"([^"]*)"'
    if num then
      num = tonumber(num)
      if not g.mesg[num] then
        g.mesg[num] = msg
      end
    end
  end
  mesg_file:close()
  return true
end

local function read_mesg()
  g.mesg = {}

  local file_dir = util.get_vim_variable "s:FILE_DIR"
  local mesg_fname = vim.g["rogue#message"]
  if type(mesg_fname) == "string" and mesg_fname ~= "" then
    mesg_fname = g.expand_fname(mesg_fname, file_dir)
    read_mesg_file(mesg_fname)
  end

  local japanese = vim.g["rogue#japanese"]
  local lang = vim.v.lang
  if type(japanese) == "number" then
    if japanese ~= 0 then
      g.JAPAN = true
    else
      g.JAPAN = false
    end
  elseif lang:match "ja" then
    g.JAPAN = true
  else
    g.JAPAN = false
  end
  local default_f
  if g.JAPAN then
    default_f = "mesg"
  else
    default_f = "mesg_E"
  end

  local ret = read_mesg_file(file_dir .. default_f)
  if not ret then
    return false
  end

  if not g.JAPAN and g.mesg[1]:find "English" then
    g.English = true
  end

  g.save_encoding = util.get_vim_variable "s:save_encoding"
  local needs_iconv = util.get_vim_variable "s:needs_iconv"
  if needs_iconv ~= 0 then
    g.needs_iconv = true
    vim.cmd 'let &encoding = "utf-8"'
    for k, v in pairs(g.mesg) do
      g.mesg[k] = g.iconv_from_utf8(v)
    end
    vim.cmd "let &encoding = s:save_encoding"
  end
  return true
end

local function main()
  if not read_mesg() then
    print "Cannot open message file"
    return
  end
  if vim.o.columns < g.DCOLS or vim.o.lines < g.DROWS then
    vim.fn.confirm(g.mesg[14])
    return
  end
  local first = true
  g.update_flag = true

  local args = util.split(util.get_vim_variable "s:args", " ")
  if g.init(args) then
    -- restored game
    first = false
    g.refresh()
    g.play_level()
  end

  while true do
    g.free_stuff(g.level_objects)
    g.free_stuff(g.level_monsters)
    g.clear_level()
    g.make_level()
    g.put_objects()
    g.put_stairs()
    g.add_traps()
    g.put_mons()
    g.put_player(g.party_room)
    g.print_stats()
    if first then
      g.message(string.format(g.mesg[10], g.nick_name))
      first = false
    end
    g.refresh()
    g.play_level()
  end
end

function g.main()
  init_dirs()
  g.cov_start()
  local ret, err = xpcall(main, g.error_handler)
  g.cov_stop()
  -- check_global()
  g.log_close()
  if not ret and err ~= g.EXIT_SUCCESS then
    error(err)
  end
end
