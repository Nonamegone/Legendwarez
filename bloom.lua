menu.add_slider_float("Bloom scale", 0.0, 10.0)

local ffi = require("ffi")

local IClientEntityList = ffi.cast(ffi.typeof("void***"), utils.create_interface("client.dll", "VClientEntityList003"))
local GetHighestEntityIndex = ffi.cast(ffi.typeof("int(__thiscall*)(void*)"), IClientEntityList[0][6])

local FindByClass = function(name)
  for i = 64, GetHighestEntityIndex(IClientEntityList) do
    local entity = entitylist.get_player_by_index(i)
    if entity ~= nil then
      if entity:get_class_name() == name then
        return entity
      end
    end
  end
end


client.add_callback("on_paint", function()
  local CEnvTonemapController = FindByClass("CEnvTonemapController")

  if CEnvTonemapController ~= nil then
    CEnvTonemapController:set_prop_int("CEnvTonemapController", "m_bUseCustomBloomScale", 1.0)
    CEnvTonemapController:set_prop_float("CEnvTonemapController", "m_flCustomBloomScale", menu.get_float("Bloom scale"))
  end
end)

client.add_callback('unload', function()
  local CEnvTonemapController = FindByClass("CEnvTonemapController")

  if CEnvTonemapController ~= nil then
    CEnvTonemapController:set_prop_int("CEnvTonemapController", "m_bUseCustomBloomScale", 0.0)
  end
end)