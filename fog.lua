menu.add_check_box("Enable fog")
menu.add_color_picker("Fog color")
menu.add_slider_int("Start Distance", 0, 1000)
menu.add_slider_int("End Distance", 0, 2000)
menu.add_slider_int("Density", 0, 100)

client.add_callback("on_paint", function()
  if entitylist.get_local_player() ~= nil and globals.get_server_address() ~= nil then
    if menu.get_bool("Enable fog") then
      local color = menu.get_color("Fog color")
      local start_pos = menu.get_int("Start Distance")
      local end_pos = menu.get_int("End Distance")
      local density = menu.get_int("Density")
      console.set_float("fog_override", 1)
      console.set_string("fog_color", string.format("%i %i %i", color:r(), color:g(), color:b()))
      console.set_float("fog_start" , start_pos)
      console.set_float("fog_end" , end_pos)
      console.set_float("fog_maxdensity" , density /100)
    else
      console.set_float("fog_color", -1);
      console.set_float("fog_override", 0)
      console.set_float("fog_start", -1)
      console.set_float("fog_end", -1)
      console.set_float("fog_maxdensity", -1)
    end
  end
end)

client.add_callback("unload", function()
  console.set_float("fog_color", -1);
  console.set_float("fog_override", 0)
  console.set_float("fog_start", -1)
  console.set_float("fog_end", -1)
  console.set_float("fog_maxdensity", -1)
end)