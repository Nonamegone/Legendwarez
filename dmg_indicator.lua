local screen = {x = engine.get_screen_width(), y = engine.get_screen_height()}
local font = render.create_font("Verdana", 12, 0, false, true)
menu.add_check_box('Damage indicator')

local wpn2tab = {
  ['CDEagle'] = 0.0,
  ['Glock'] = 1.0,
  ['HKP2000'] = 1.0,
  ['P250'] = 1.0,
  ['Elite'] = 1.0,
  ['Tec9'] = 1.0,
  ['FiveSeven'] = 1.0,
  ['SCAR20'] = 2.0,
  ['G3SG1'] = 2.0,
  ['SSG08'] = 3.0,
  ['AWP'] = 4.0,
  ['CAK47'] = 5.0,
  ['M4A1'] = 5.0,
  ['SG556'] = 5.0,
  ['Aug'] = 5.0,
  ['GalilAR'] = 5.0,
  ['Famas'] = 5.0,
  ['MAC10'] = 6.0,
  ['UMP45'] = 6.0,
  ['MP7'] = 6.0,
  ['MP9'] = 6.0,
  ['P90'] = 6.0,
  ['Bizon'] = 6.0,
  ['NOVA'] = 7.0,
  ['XM1014'] = 7.0,
  ['Sawedoff'] = 7.0,
  ['Mag7'] = 7.0,
  ['M249'] = 8.0,
  ['Negev'] = 8.0,
}



client.add_callback('on_paint', function()
  if not menu.get_bool('Damage indicator') then return end
  
  local player = entitylist.get_local_player()
  if not player then return end

  local weapon = entitylist.get_weapon_by_player(player)
  if not weapon then return end

  weapon = weapon:get_class_name():gsub('CWeapon', '')
  local current = wpn2tab[weapon] or nil

  if current ~= nil then
    local damage = menu.get_int(string.format('rage.weapon[%s].%s   ', current, menu.get_key_bind_state('rage.force_damage_key') and 'force_damage_value' or 'minimum_damage'))
    render.draw_text_centered(font, screen.x /2 + 5.0, screen.y /2 - 15.0, color.new(255, 255, 255), false, false, string.format('%s', damage))
  end
end)