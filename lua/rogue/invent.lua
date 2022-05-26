local g = Rogue -- alias
local mesg = require "rogue.mesg"
local random = require "rogue.random"
local util = require "rogue.util"

g.is_wood = {}

local wand_materials = {}
local gems = {}
local syllables = {}

function g.init_invent()
  wand_materials = {
    [0] = mesg[410],
    mesg[411],
    mesg[412],
    mesg[413],
    mesg[414],
    mesg[415],
    mesg[416],
    mesg[417],
    mesg[418],
    mesg[419],
    mesg[420],
    mesg[421],
    mesg[422],
    mesg[423],
    mesg[424],
    mesg[425],
    mesg[426],
    mesg[427],
    mesg[428],
    mesg[429],
    mesg[430],
    mesg[431],
    mesg[432],
    mesg[433],
    mesg[434],
    mesg[435],
    mesg[436],
    mesg[437],
    mesg[438],
    mesg[439],
  }

  gems = {
    [0] = mesg[440],
    mesg[441],
    mesg[442],
    mesg[443],
    mesg[444],
    mesg[445],
    mesg[446],
    mesg[447],
    mesg[448],
    mesg[449],
    mesg[450],
    mesg[451],
    mesg[452],
    mesg[453],
  }

  syllables = {
    [0] = mesg[454],
    mesg[455],
    mesg[456],
    mesg[457],
    mesg[458],
    mesg[459],
    mesg[460],
    mesg[461],
    mesg[462],
    mesg[463],
    mesg[464],
    mesg[465],
    mesg[466],
    mesg[467],
    mesg[468],
    mesg[469],
    mesg[470],
    mesg[471],
    mesg[472],
    mesg[473],
    mesg[474],
    mesg[475],
    mesg[476],
    mesg[477],
    mesg[478],
    mesg[479],
    mesg[480],
    mesg[481],
    mesg[482],
    mesg[483],
    mesg[484],
    mesg[485],
    mesg[486],
    mesg[487],
    mesg[488],
    mesg[489],
    mesg[490],
    mesg[491],
    mesg[492],
    mesg[493],
  }
end

local function Protected(obj)
  return obj.what_is == g.ARMOR and obj.is_protected
end

function g.inventory(pack, mask)
  local row
  local col
  local msg = " " .. mesg[494]
  if mesg.JAPAN then
    msg = " " .. msg
  end
  local len = util.strwidth(msg)

  local obj = pack.next_object
  if not obj then
    g.message(mesg[26])
    return
  end

  if type(mask) == "number" then
    mask = { [mask] = true }
  end

  repeat
    -- ::nextpage::
    local nextpg = false
    local i = 0
    local maxlen = len
    while obj and i < g.DROWS - 2 do
      if mask[obj.what_is] then
        g.descs[i] = " "
          .. obj.ichar
          .. (Protected(obj) and "}" or ")")
          .. " "
          .. g.get_desc(obj, false)
        local n = util.strwidth(g.descs[i])
        if n > maxlen then
          maxlen = n
        end
        i = i + 1
      end
      obj = obj.next_object
    end
    g.descs[i] = msg
    i = i + 1

    if i == 0 then
      return
    end

    col = g.DCOLS - (maxlen + 2 + 1)
    for row = 0, i - 1 do
      g.mvaddstr(row, col, g.descs[row])
    end
    g.refresh()
    g.wait_for_ack()
    for row = 0, g.DROWS - 2 do
      g.mvaddstr(row, 0, "")
    end

    if obj then
      -- goto nextpage
      nextpg = true
    end
  until not nextpg
end

function g.mix_colors()
  for i = 0, g.POTIONS - 1 do
    g.id_potions[i].title = g.po_color[i]
  end
  for i = 0, g.POTIONS - 1 do
    local j = random.get_rand(i, g.POTIONS - 1)
    g.id_potions[i].title, g.id_potions[j].title =
      g.id_potions[j].title, g.id_potions[i].title
  end
end

function g.make_scroll_titles()
  for i = 0, g.SCROLS - 1 do
    local sylls = random.get_rand(2, 5)
    g.id_scrolls[i].title = mesg[535]
    local len = util.strwidth(g.id_scrolls[i].title)
    for j = 0, sylls - 1 do
      local s = random.get_rand(1, g.MAXSYLLABLES - 1)
      local n = util.strwidth(syllables[s])
      if len + n - 1 >= g.MAX_TITLE_LENGTH - 2 then
        break
      end
      g.id_scrolls[i].title = g.id_scrolls[i].title .. syllables[s]
      len = len + n
    end
    g.id_scrolls[i].title = g.id_scrolls[i].title:gsub(" $", "")
    g.id_scrolls[i].title = g.id_scrolls[i].title .. mesg[536]
  end
end

local function get_desc_ANA(obj)
  if obj.in_use_flags == g.BEING_WIELDED then
    return mesg[35]
  elseif obj.in_use_flags == g.BEING_WORN then
    return mesg[36]
  elseif obj.in_use_flags == g.ON_LEFT_HAND then
    return mesg[37]
  elseif obj.in_use_flags == g.ON_RIGHT_HAND then
    return mesg[38]
  else
    return ""
  end
end

local function capitalize(str, capitalized)
  if capitalized then
    return str:upper():sub(1, 1) .. str:sub(2)
  else
    return str:lower():sub(1, 1) .. str:sub(2)
  end
end

function g.get_desc(obj, capitalized)
  local desc = ""
  if obj.what_is == g.AMULET then
    desc = mesg[27]
    if mesg.English and not capitalized then
      desc = capitalize(desc, false)
    end
    return desc
  end
  local item_name = g.name_of(obj)
  if mesg.JAPAN then
    if obj.what_is == g.GOLD then
      desc = g.znum(obj.quantity)
      desc = desc .. mesg[28]
      return desc
    end
    if obj.what_is == g.WEAPON and obj.quantity > 1 then
      desc = g.znum(obj.quantity)
      desc = desc .. mesg[29]
    elseif obj.what_is == g.FOOD then
      desc = g.znum(obj.quantity)
      desc = desc .. ((obj.which_kind == g.RATION) and mesg[30] or mesg[31])
      desc = desc .. item_name
      -- goto ANA
      desc = desc .. get_desc_ANA(obj)
      return desc
    elseif obj.what_is ~= g.ARMOR and obj.quantity > 1 then
      desc = g.znum(obj.quantity)
      desc = desc .. mesg[32]
    end
  else
    if obj.what_is == g.GOLD then
      desc = string.format(mesg[28], obj.quantity)
      return desc
    end
    if obj.what_is ~= g.ARMOR then
      if mesg.English and obj.quantity == 1 then
        desc = capitalize("a ", capitalized)
      else
        desc = string.format(mesg[29], obj.quantity)
      end
    end
    if obj.what_is == g.FOOD then
      if obj.which_kind == g.RATION then
        if mesg.English and obj.quantity == 1 then
          desc = capitalize(mesg[32], capitalized)
        else
          desc = string.format(mesg[30], obj.quantity)
        end
      else
        if mesg.English and obj.quantity == 1 then
          desc = capitalize("a ", capitalized)
        else
          desc = string.format(mesg[29], obj.quantity)
        end
      end
      desc = desc .. item_name
      -- goto ANA
      desc = desc .. get_desc_ANA(obj)
      return desc
    end
  end
  local id_table = g.get_id_table(obj)

  local goto_CHECK_flag = nil
  local goto_ID_flag = nil
  local goto_CALL_flag = nil
  if g.wizard then
    -- goto ID
    goto_ID_flag = true
  elseif
    obj.what_is == g.WEAPON
    or obj.what_is == g.ARMOR
    or obj.what_is == g.WAND
    or obj.what_is == g.RING
  then
    -- goto CHECK
    goto_CHECK_flag = true
  end

  local id_status = id_table[obj.which_kind].id_status
  if not goto_ID_flag and (goto_CHECK_flag or id_status == g.UNIDENTIFIED) then
    -- ::CHECK::
    goto_CHECK_flag = true
    if obj.what_is == g.SCROL then
      if mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].title .. mesg[33] .. item_name
      else
        desc = desc .. item_name .. mesg[33] .. id_table[obj.which_kind].title
      end
    elseif obj.what_is == g.POTION then
      desc = desc .. id_table[obj.which_kind].title .. item_name
    elseif obj.what_is == g.WAND or obj.what_is == g.RING then
      if obj.identified or (id_status == g.IDENTIFIED) then
        -- goto ID
        goto_ID_flag = true
      elseif id_status == g.CALLED then
        -- goto CALL
        goto_CALL_flag = true
      else
        desc = desc .. id_table[obj.which_kind].title .. item_name
      end
    elseif obj.what_is == g.ARMOR then
      if obj.identified then
        -- goto ID
        goto_ID_flag = true
      else
        desc = desc .. id_table[obj.which_kind].title
      end
    elseif obj.what_is == g.WEAPON then
      if obj.identified then
        -- goto ID
        goto_ID_flag = true
      else
        desc = desc .. g.name_of(obj)
      end
    end
  end
  if goto_ID_flag or (not goto_CHECK_flag and id_status == g.IDENTIFIED) then
    -- ::ID::
    if obj.what_is == g.SCROL or obj.what_is == g.POTION then
      if mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].real .. item_name
      else
        desc = desc .. item_name .. id_table[obj.which_kind].real
      end
    elseif obj.what_is == g.RING then
      if mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].real
      end
      if g.wizard or obj.identified then
        if
          obj.which_kind == g.DEXTERITY or obj.which_kind == g.ADD_STRENGTH
        then
          desc = desc .. mesg[537] .. g.znum(obj.class, true) .. mesg[538]
        end
      end
      desc = desc .. item_name
      if not mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].real
      end
    elseif obj.what_is == g.WAND then
      if mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].real .. item_name
      else
        desc = desc .. item_name .. id_table[obj.which_kind].real
      end
      if g.wizard or obj.identified then
        desc = desc .. mesg[539] .. g.znum(obj.class) .. mesg[540]
      end
    elseif obj.what_is == g.ARMOR then
      desc = desc .. mesg[537] .. g.znum(obj.d_enchant, true) .. mesg[538]
      desc = desc .. id_table[obj.which_kind].title
      desc = desc .. mesg[539] .. g.znum(g.get_armor_class(obj)) .. mesg[540]
    elseif obj.what_is == g.WEAPON then
      desc = desc .. mesg[537] .. g.znum(obj.hit_enchant, true)
      desc = desc .. mesg[541] .. g.znum(obj.d_enchant, true) .. mesg[538]
      desc = desc .. g.name_of(obj)
    end
  elseif goto_CALL_flag or (not goto_CHECK_flag and id_status == g.CALLED) then
    -- ::CALL::
    if
      obj.what_is == g.SCROL
      or obj.what_is == g.POTION
      or obj.what_is == g.WAND
      or obj.what_is == g.RING
    then
      if mesg.JAPAN then
        desc = desc .. id_table[obj.which_kind].title .. mesg[34] .. item_name
      else
        desc = desc .. item_name .. mesg[34] .. id_table[obj.which_kind].title
      end
    end
  end
  -- ::ANA::
  desc = desc .. get_desc_ANA(obj)
  return desc
end

function g.get_wand_and_ring_materials()
  local j
  local used = {}
  for i = 0, g.WANDS - 1 do
    repeat
      j = random.get_rand(0, g.WAND_MATERIALS - 1)
    until not used[j]
    used[j] = true
    g.id_wands[i].title = wand_materials[j] .. mesg[39]
    g.is_wood[i] = (j > g.MAX_METAL)
  end
  used = {}
  for i = 0, g.RINGS - 1 do
    repeat
      j = random.get_rand(0, g.GEMS - 1)
    until not used[j]
    used[j] = true
    g.id_rings[i].title = gems[j] .. mesg[40]
  end
end

function g.single_inv(ichar)
  local ch = (ichar and ichar or g.pack_letter(mesg[41], g.ALL_OBJECTS))

  if ch == g.CANCEL then
    return
  end
  local obj = g.get_letter_object(ch)
  if not obj then
    g.message(mesg[41])
    return
  end
  local desc = ch
  desc = desc .. ((obj.what_is == g.ARMOR and obj.is_protected) and "}" or ")")
  desc = desc .. " "
  desc = desc .. g.get_desc(obj, true)
  g.message(desc)
end

function g.get_id_table(obj)
  if obj.what_is == g.SCROL then
    return g.id_scrolls
  elseif obj.what_is == g.POTION then
    return g.id_potions
  elseif obj.what_is == g.WAND then
    return g.id_wands
  elseif obj.what_is == g.RING then
    return g.id_rings
  elseif obj.what_is == g.WEAPON then
    return g.id_weapons
  elseif obj.what_is == g.ARMOR then
    return g.id_armors
  end
  return nil
end

function g.inv_weapon()
  if g.rogue.weapon then
    g.single_inv(g.rogue.weapon.ichar)
  else
    g.message(mesg[43])
  end
end

function g.inv_armor()
  if g.rogue.armor then
    g.single_inv(g.rogue.armor.ichar)
  else
    g.message(mesg[44])
  end
end

function g.discovered()
  local msg = " " .. mesg[494]
  if mesg.JAPAN then
    msg = " " .. msg
  end
  local len = util.strwidth(msg)

  g.message(mesg[45])
  local ch
  while true do
    ch = g.rgetchar()
    if ch == g.CANCEL then
      g.check_message()
      return
    elseif string.find("?!=/*", ch, 1, true) then
      g.check_message()
      break
    else
      g.sound_bell()
    end
  end

  local found = {}
  local dobj = {
    {
      type = g.SCROL,
      ch = "?",
      max = g.SCROLS,
      name = mesg[3],
      id = g.id_scrolls,
    },
    {
      type = g.POTION,
      ch = "!",
      max = g.POTIONS,
      name = mesg[4],
      id = g.id_potions,
    },
    {
      type = g.WAND,
      ch = "/",
      max = g.WANDS,
      name = mesg[5],
      id = g.id_wands,
    },
    {
      type = g.RING,
      ch = "=",
      max = g.RINGS,
      name = mesg[8],
      id = g.id_rings,
    },
  }
  local dlist = {}
  local dp = {}

  for idx, op in ipairs(dobj) do
    if ch == op.ch or ch == "*" then
      for i = 0, op.max - 1 do
        local j = op.id[i].id_status
        if j == g.IDENTIFIED or j == g.CALLED then
          dp.type = op.type
          dp.no = i
          dp.name = op.name
          if g.wizard or j == g.IDENTIFIED then
            dp.real = op.id[i].real
            dp.sub = ""
          else
            dp.real = op.id[i].title
            dp.sub = mesg[34]
          end

          if not mesg.JAPAN then
            if op.type == g.WAND and g.is_wood[i] then
              dp.name = mesg[6]
            end
          end
          found[op.type] = true
          table.insert(dlist, dp)
          dp = {}
        end
      end
      if not found[op.type] then
        dp.type = op.type
        dp.no = -1
        dp.name = op.name
        if mesg.English then
          -- add "s" of the plural
          dp.name = dp.name:gsub(" ", "s ")
        end
        table.insert(dlist, dp)
        dp = {}
      end
      dp.type = 0
      table.insert(dlist, dp)
      dp = {}
    end
  end

  if vim.tbl_isempty(found) then
    g.message(mesg[46])
    return
  end

  local d_idx = 1
  dp = dlist[d_idx]
  repeat
    -- ::nextpage::
    local nextpg = false
    local i = 0
    local maxlen = len
    while d_idx <= #dlist and i < g.DROWS - 2 do
      if dp.type == 0 then
        g.descs[i] = " "
      elseif dp.no < 0 then
        g.descs[i] = string.format(mesg[47], dp.name)
      else
        if mesg.JAPAN then
          g.descs[i] = "  " .. dp.real .. dp.sub .. dp.name
        elseif mesg.English then
          g.descs[i] = " " .. capitalize(dp.name, true) .. dp.real
        else
          g.descs[i] = " " .. dp.name .. dp.real
        end
      end
      local n = util.strwidth(g.descs[i])
      if n > maxlen then
        maxlen = n
      end
      i = i + 1
      d_idx = d_idx + 1
      dp = dlist[d_idx]
    end

    if i == 0 or i == 1 and g.descs[0] == "" then
      -- can be here only in 2nd pass (exactly one page)
      return
    end

    g.descs[i] = msg
    i = i + 1

    local col = g.DCOLS - (maxlen + 2 + 1)
    for row = 0, i - 1 do
      g.mvaddstr(row, col, g.descs[row])
    end
    g.refresh()
    g.wait_for_ack()
    for row = 0, g.DROWS - 2 do
      g.mvaddstr(row, 0, "")
    end

    if d_idx <= #dlist then
      -- goto nextpage
      nextpg = true
    end
  until not nextpg
end

function g.znum(n, plus)
  local z_num_list = {
    [0] = mesg[523],
    [1] = mesg[524],
    [2] = mesg[525],
    [3] = mesg[526],
    [4] = mesg[527],
    [5] = mesg[528],
    [6] = mesg[529],
    [7] = mesg[530],
    [8] = mesg[531],
    [9] = mesg[532],
  }
  local z_num_plus = mesg[533]
  local z_num_minus = mesg[534]

  local str = ""
  if plus and n >= 0 then
    str = str .. z_num_plus
  end
  local tmp = string.format("%d", n)
  for i = 1, #tmp do
    local c = tmp:sub(i, i)
    if c == "-" then
      str = str .. z_num_minus
    else
      str = str .. z_num_list[tonumber(c)]
    end
  end
  return str
end
