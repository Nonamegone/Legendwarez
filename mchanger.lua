local ffi = require('ffi')

--HOOKS
ffi.cdef [[
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
    void* VirtualAlloc(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect);
    int VirtualFree(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);
]]

function GetModuleHandle(file)
    return ffi.C.GetModuleHandleA(file)
end

local function copy(dst, src, len)
    return ffi.copy(ffi.cast('void*', dst), ffi.cast('const void*', src), len)
end
local buff = {free = {}}
local function VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect)
    return ffi.C.VirtualProtect(ffi.cast('void*', lpAddress), dwSize, flNewProtect, lpflOldProtect)
end
local function VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect, blFree)
    local alloc = ffi.C.VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)
    if blFree then
        table.insert(buff.free, function()
            ffi.C.VirtualFree(alloc, 0, 0x8000)
        end)
    end
    return ffi.cast('intptr_t', alloc)
end
--VMT HOOKS
local vmt_hook = {hooks = {}}
function vmt_hook.new(vt)
    local new_hook = {}
    local org_func = {}
    local old_prot = ffi.new('unsigned long[1]')
    local virtual_table = ffi.cast('intptr_t**', vt)[0]
    new_hook.this = virtual_table
    new_hook.hookMethod = function(cast, func, method)
        org_func[method] = virtual_table[method]
        VirtualProtect(virtual_table + method, 4, 0x4, old_prot)
        virtual_table[method] = ffi.cast('intptr_t', ffi.cast(cast, func))
        VirtualProtect(virtual_table + method, 4, old_prot[0], old_prot)
        return ffi.cast(cast, org_func[method])
    end
    new_hook.unHookMethod = function(method)
        VirtualProtect(virtual_table + method, 4, 0x4, old_prot)
        -- virtual_table[method] = org_func[method]
        local alloc_addr = VirtualAlloc(nil, 5, 0x1000, 0x40, false)
        local trampoline_bytes = ffi.new('uint8_t[?]', 5, 0x90)
        trampoline_bytes[0] = 0xE9
        ffi.cast('int32_t*', trampoline_bytes + 1)[0] = org_func[method] - tonumber(alloc_addr) - 5
        copy(alloc_addr, trampoline_bytes, 5)
        virtual_table[method] = ffi.cast('intptr_t', alloc_addr)
        VirtualProtect(virtual_table + method, 4, old_prot[0], old_prot)
        org_func[method] = nil
    end
    new_hook.unHookAll = function()
        for method, func in pairs(org_func) do
            new_hook.unHookMethod(method)
        end
    end
    table.insert(vmt_hook.hooks, new_hook.unHookAll)
    return new_hook
end
--VMT HOOKS
client.add_callback( 'unload', function()
    for i, unHookFunc in ipairs(vmt_hook.hooks) do
        unHookFunc()
    end
end)
--local fsninter = utils.create_interface( "client.dll", "VClient018" )

-------------------------WEATHER START------------------------------
-------------------------WEATHER START------------------------------
-------------------------WEATHER START------------------------------
local customplayers = {
	{ "Sinon", "models/player/custom_player/kolka/Sinon/sinon.mdl" },
    { "Fuku", "models/player/custom_player/toppiofficial/gf/ump45.mdl" },
    { "Cardigan", "models/player/custom_player/toppiofficial/arknight/cardigan.mdl" },
    { "Hu Tao", "models/player/custom_player/toppiofficial/genshin/hutao.mdl" },
    { "AMOGUS", "models/player/custom_player/owston/amongus/white.mdl" },
}

ffi.cdef[[
    typedef struct 
    {
    	void*   fnHandle;        
    	char    szName[260];     
    	int     nLoadFlags;      
    	int     nServerCount;    
    	int     type;            
    	int     flags;           
    	float  vecMins[3];       
    	float  vecMaxs[3];       
    	float   radius;          
    	char    pad[0x1C];       
    }model_t;
    
    typedef void(__cdecl* ForceUpdateFn)();
    typedef int(__thiscall* get_model_index_t)(void*, const char*);
    typedef const model_t(__thiscall* find_or_load_model_t)(void*, const char*);
    typedef int(__thiscall* add_string_t)(void*, bool, const char*, int, const void*);
    typedef void*(__thiscall* find_table_t)(void*, const char*);
    typedef void(__thiscall* set_model_index_t)(void*, int);
    typedef int(__thiscall* precache_model_t)(void*, const char*, bool);
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
]]

local class_ptr = ffi.typeof("void***")
local void_ptr = ffi.typeof("void*")

local rawientitylist = utils.create_interface("client.dll", "VClientEntityList003") or print("VClientEntityList003 wasnt found")
local ientitylist = ffi.cast(class_ptr, rawientitylist) or print("rawientitylist is nil")
local get_client_entity = ffi.cast("get_client_entity_t", ientitylist[0][3]) or print("get_client_entity is nil")

local rawivmodelinfo = utils.create_interface("engine.dll", "VModelInfoClient004") or print("VModelInfoClient004 wasnt found")
local ivmodelinfo = ffi.cast(class_ptr, rawivmodelinfo) or print("rawivmodelinfo is nil")
local get_model_index = ffi.cast("get_model_index_t", ivmodelinfo[0][2]) or print("get_model_info is nil")
local find_or_load_model = ffi.cast("find_or_load_model_t", ivmodelinfo[0][39]) or print("find_or_load_model is nil")

local rawnetworkstringtablecontainer = utils.create_interface("engine.dll", "VEngineClientStringTable001") or print("VEngineClientStringTable001 wasnt found")
local networkstringtablecontainer = ffi.cast(class_ptr, rawnetworkstringtablecontainer) or print("rawnetworkstringtablecontainer is nil")
local find_table = ffi.cast("find_table_t", networkstringtablecontainer[0][3]) or print("find_table is nil")
local force_updatefn = utils.find_signature( 'engine.dll',   "A1 ? ? ? ? B9 ? ? ? ? 56 FF 50 14 8B 34 85" )
local force_update = ffi.cast("ForceUpdateFn", force_updatefn)

local model_names = {}
for k,v in pairs(customplayers) do
    table.insert(model_names, v[1])
end

menu.add_combo_box( 'Mdl', model_names )

local function precache_model(modelname)
	local rawprecache_table = find_table(networkstringtablecontainer, "modelprecache") or print("couldnt find modelprecache")
	if rawprecache_table then
		local precache_table = ffi.cast(class_ptr, rawprecache_table) or print("couldnt cast precache_table")
		if precache_table then
			local add_string = ffi.cast("add_string_t", precache_table[0][8]) or print("add_string is nil")
            local emtpy_void_ptr = ffi.cast(void_ptr, 0)

			find_or_load_model(ivmodelinfo, modelname)
			local idx = add_string(precache_table, false, modelname, -1, emtpy_void_ptr)
			if idx == -1 then
			  return false
			end
		end
	end
	return true
end

local function set_model_index(entity, idx)
    local raw_entity = get_client_entity(ientitylist, entity)
    if raw_entity then 
        local gce_entity = ffi.cast(class_ptr, raw_entity)
        local a_set_model_index = ffi.cast("set_model_index_t", gce_entity[0][75])
        if a_set_model_index == nil then 
            print("set_model_index is nil")
        end
        a_set_model_index(gce_entity, idx)
    end
end

local function change_model(ent, model)
    if model:len() > 5 then 
        if precache_model(model) == false then 
            print("invalid model")
        end
        local idx = get_model_index(ivmodelinfo, model)
        if idx == -1 then 
            return
        end
        set_model_index(ent, idx)
    end
end

local team_references, team_model_paths = {}, {}
local model_index_prev
local model_name, model_path, model_is_t

local l_i = 0
local oldcboxint = 0
local update_skins = true
function modelchanger(stage)
    
    if stage ~= 4 then return end

    local me = engine.get_local_player_index()
    if me == nil then return end

    local cboxint = menu.get_int( 'Mdl' ) + 1
    --print(tostring(customplayers[cboxint][2]))

    change_model(me, customplayers[cboxint][2])
    --print(tostring(upd_model))
    --console.execute( 'cl_fullupdate' )
end
-------------------------WEATHER END--------------------------------
-------------------------WEATHER END--------------------------------
-------------------------WEATHER END--------------------------------

local CMInt = utils.create_interface( "client.dll", "VClient018" )
local Client = vmt_hook.new(CMInt)

function fsnweather(stage)
    modelchanger(stage)
    res = fsn(stage)
    return res
end

fsn = Client.hookMethod("void(__stdcall *)(int Stage)", fsnweather, 37)