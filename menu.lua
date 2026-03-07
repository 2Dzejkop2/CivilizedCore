--[[
───────────────────────────────────────────────────────────────

	SEM_InteractionMenu (menu.lua) - Created by Scott M
	Current Version: v1.7.1 (Sep 2021) - FIXED VERSION
	
	Support | https://semdevelopment.com/discord
	
        !!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

───────────────────────────────────────────────────────────────
]]

Citizen.CreateThread(function()
    AddTextEntry('chalet-london', 'fonts/chalet_london.ttf')
end)

-- Define the default font for the menu
local font = 0
local size = 0.3
local fontName = "chalet-london"
local fontColour = {255, 255, 255, 255}

-- Menu orientation setup
local MenuOri = 0
if Config.MenuOrientation == 0 then
    MenuOri = 0
elseif Config.MenuOrientation == 1 then
    MenuOri = 1320
else
    MenuOri = 0
end

-- Menu pool initialization
_MenuPool = NativeUI.CreatePool()
MainMenu = NativeUI.CreateMenu()

-- Enhanced Staff Jail Configuration Fallbacks
Config.StaffMaxJailTime = Config.StaffMaxJailTime or 1800 -- 30 minutes default
Config.AdvancedStaffJail = Config.AdvancedStaffJail or {Enabled = true}
Config.MaxJailTime = Config.MaxJailTime or 3600 -- 1 hour default for LEO jail
Config.MaxHospitalTime = Config.MaxHospitalTime or 1800 -- 30 minutes default

-- Enhanced error handling for input validation
local function ValidatePlayerID(input)
    local id = tonumber(input)
    if not id or id < 1 or id > 1000 then
        return nil
    end
    return id
end

local function ValidateTimeInput(input, maxTime, defaultTime)
    local time = tonumber(input)
    if not time then
        return defaultTime or 30
    end
    if time < 1 then
        return 1
    end
    if time > maxTime then
        return maxTime
    end
    return time
end

local function ValidateComInput(input)
    local coms = tonumber(input)
    if not coms then
        return 5 -- Default
    end
    if coms < 1 then
        return 1
    end
    if coms > 50 then
        return 50
    end
    return coms
end

-- Enhanced keyboard input with better validation
local function EnhancedKeyboardInput(prompt, maxLength, inputType)
    local input = KeyboardInput(prompt, maxLength or 10)
    
    if inputType == "playerid" then
        return ValidatePlayerID(input)
    elseif inputType == "coms" then
        return ValidateComInput(input)
    elseif inputType == "time" then
        return ValidateTimeInput(input, Config.MaxJailTime, 30)
    elseif inputType == "hospitaltime" then
        return ValidateTimeInput(input, Config.MaxHospitalTime, 30)
    else
        return input
    end
end

function Menu()
    local MenuTitle = ''
    if Config.MenuTitle == 0 then
        MenuTitle = 'Interaction Menu'
    elseif Config.MenuTitle == 1 then
        MenuTitle = GetPlayerName(PlayerId()) or 'Interaction Menu'
    elseif Config.MenuTitle == 2 then
        MenuTitle = Config.MenuTitleCustom or 'Interaction Menu'
    else
        MenuTitle = 'Interaction Menu'
    end

    _MenuPool:Remove()
    _MenuPool = NativeUI.CreatePool()
    MainMenu = NativeUI.CreateMenu("Civilized Core", "~r~Civilized Core ~y~v1.14", MenuOri)
    _MenuPool:Add(MainMenu)
    MainMenu:SetMenuWidthOffset(Config.MenuWidth)
    collectgarbage()

    MainMenu:SetMenuWidthOffset(Config.MenuWidth)    
    _MenuPool:ControlDisablingEnabled(false)
    _MenuPool:MouseControlsEnabled(false)

    -- Enhanced LEO Menu
    if LEORestrict() then
        local LEOMenu = _MenuPool:AddSubMenu(MainMenu, '~b~~h~Police Menu', 'Law Enforcement Related Menu', true)
        LEOMenu:SetMenuWidthOffset(Config.MenuWidth)
            local LEOActions = _MenuPool:AddSubMenu(LEOMenu, 'Actions', '', true)
            LEOActions:SetMenuWidthOffset(Config.MenuWidth)
                local Cuff = NativeUI.CreateItem('~b~Cuff Player', 'Cuff/Uncuff the closest player')
                local Drag = NativeUI.CreateItem('~b~Drag Player', 'Drag/Undrag the closest player')
                local Seat = NativeUI.CreateItem('~b~Seat Player', 'Place a player in the closest vehicle')
                local Unseat = NativeUI.CreateItem('~b~Unseat Player', 'Remove a player from the closest vehicle')
                local Radar = NativeUI.CreateItem('~b~Radar ~h~~r~[WORK IN PROGRESS]', 'Toggle the radar menu')
                local Inventory = NativeUI.CreateItem('~b~Inventory ~h~~r~[WORK IN PROGRESS]', 'Search the closest player\'s inventory')
                local BAC = NativeUI.CreateItem('~b~BAC ~h~~r~[WORK IN PROGRESS]', 'Test the BAC level of the closest player')
                local Jail = NativeUI.CreateItem('~b~Jail Player', 'Jail a player (LEO System)')
                local Unjail = NativeUI.CreateItem('~b~Unjail Player', 'Unjail a player (LEO System)')
                SpikeLengths = {1, 2, 3, 4, 5}
                local Spikes = NativeUI.CreateListItem('Deploy Spikes', SpikeLengths, 1, 'Places spike strips on the ground')
                local DelSpikes = NativeUI.CreateItem('Remove Spikes', 'Remove spike strips placed on the ground')
                local Shield = NativeUI.CreateItem('Toggle Shield', 'Toggle the bulletproof shield')
                local CarbineRifle = NativeUI.CreateItem('Toggle Carbine', 'Toggle your carbine rifle')
                local Shotgun = NativeUI.CreateItem('Toggle Shotgun', 'Toggle your pump shotgun')
                local Guidebook = NativeUI.CreateItem('~b~Guidebook', 'Open the guidebook menu')
                
                PropsList = {}
                if Config.Props then
                    for _, Prop in pairs(Config.Props) do
                        table.insert(PropsList, Prop.name)
                    end
                end
                local Props = NativeUI.CreateListItem('Spawn Props', PropsList, 1, 'Spawn props on the ground')
                local RemoveProps = NativeUI.CreateItem('Remove Props', 'Remove the closest prop')
                
                LEOActions:AddItem(Cuff)
                LEOActions:AddItem(Drag)
                LEOActions:AddItem(Seat)
                LEOActions:AddItem(Unseat)
                LEOActions:AddItem(Guidebook)
                if Config.Radar ~= 0 then
                    LEOActions:AddItem(Radar)
                end
                LEOActions:AddItem(Inventory)
                LEOActions:AddItem(BAC)
                if Config.LEOJail then
                    LEOActions:AddItem(Jail)
                    if UnjailAllowed then
                        LEOActions:AddItem(Unjail)
                    end
                end
                LEOActions:AddItem(Spikes)
                LEOActions:AddItem(DelSpikes)
                LEOActions:AddItem(Shield)
                if Config.UnrackWeapons == 1 or Config.UnrackWeapons == 2 then
                    LEOActions:AddItem(CarbineRifle)
                    LEOActions:AddItem(Shotgun)
                end
                if Config.DisplayProps and #PropsList > 0 then
                    LEOActions:AddItem(Props)
                    LEOActions:AddItem(RemoveProps)
                end
                
                -- Enhanced action handlers with better error handling
                Cuff.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:CuffNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Drag.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Seat.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:SeatNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Guidebook.Activated = function(ParentMenu, SelectedItem)
                    ExecuteCommand('guidebook')
                end
                
                Unseat.Activated = function(ParentMenu, SelectedItem)
                    if IsPedInAnyVehicle(PlayerPedId(), true) then
                        Notify('~o~You need to be outside of the vehicle')
                        return
                    end

                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:UnseatNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Radar.Activated = function(ParentMenu, SelectedItem)
                    if ToggleRadar then
                        ToggleRadar()
                    else
                        Notify('~r~Radar system not available')
                    end
                end
                
                Inventory.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        Notify('~b~Searching ...')
                        TriggerServerEvent('SEM_InteractionMenu:InventorySearch', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                BAC.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        Notify('~b~Testing ...')
                        TriggerServerEvent('SEM_InteractionMenu:BACTest', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                -- Enhanced LEO Jail handler (traditional time-based system)
                Jail.Activated = function(ParentMenu, SelectedItem)
                    local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                    if PlayerID == nil then
                        Notify('~r~Please enter a valid player ID (1-1000)')
                        return
                    end
                
                    local JailTime = EnhancedKeyboardInput('Time: (Seconds) - Max Time: ' .. Config.MaxJailTime .. ' | Default Time: 30', string.len(tostring(Config.MaxJailTime)), "time")
                    if JailTime == nil then
                        JailTime = 30
                    end
                    if JailTime > Config.MaxJailTime then
                        Notify('~y~Exceeded Max Time\nMax Time: ' .. Config.MaxJailTime .. ' seconds')
                        JailTime = Config.MaxJailTime
                    end
                
                    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 500)
                    while UpdateOnscreenKeyboard() == 0 do
                        DisableAllControlActions(0)
                        Wait(0)
                    end
                    
                    local JailReason = GetOnscreenKeyboardResult()
                    if JailReason == nil or JailReason == '' then
                        Notify('~r~Please enter a reason.')
                        return
                    end
                
                    Notify('Player Jailed for ~b~' .. JailTime .. ' seconds. Reason: ' .. JailReason)
                    TriggerServerEvent('SEM_InteractionMenu:Jail', PlayerID, JailTime, JailReason)
                end
                
                Unjail.Activated = function(ParentMenu, SelectedItem)
                    local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                    if PlayerID == nil then
                        Notify('~r~Please enter a valid player ID')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:Unjail', PlayerID)
                    Notify('~g~Unjail request sent for player ID: ' .. PlayerID)
                end
                
                DelSpikes.Activated = function(ParentMenu, SelectedItem)
                    TriggerEvent('SEM_InteractionMenu:Spikes-DeleteSpikes')
                end
                
                Shield.Activated = function(ParentMenu, SelectedItem)
                    if ShieldActive then
                        if DisableShield then
                            DisableShield()
                        end
                    else
                        if EnableShield then
                            EnableShield()
                        end
                    end
                end
                
                CarbineRifle.Activated = function(ParentMenu, SelectedItem)
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle ~= 0 and GetVehicleClass(vehicle) == 18 then
                        CarbineEquipped = not CarbineEquipped
                        ShotgunEquipped = false
                        
                        if CarbineEquipped then
                            Notify('~g~Carbine Rifle Equipped')
                            GiveWeapon('weapon_carbinerifle')
                            AddWeaponComponent('weapon_carbinerifle', 'component_at_ar_flsh')
                            AddWeaponComponent('weapon_carbinerifle', 'component_at_ar_afgrip')
                        else 
                            Notify('~y~Carbine Rifle Unequipped')
                            RemoveWeaponFromPed(PlayerPedId(), 'weapon_carbinerifle')
                        end
                    else
                        Notify('~r~You Must be in a Police Vehicle to rack/unrack your Carbine Rifle')
                    end
                end
                
                Shotgun.Activated = function(ParentMenu, SelectedItem)
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle ~= 0 and GetVehicleClass(vehicle) == 18 then
                        ShotgunEquipped = not ShotgunEquipped
                        CarbineEquipped = false
                        
                        if ShotgunEquipped then
                            Notify('~g~Shotgun Equipped')
                            GiveWeapon('weapon_pumpshotgun')
                            AddWeaponComponent('weapon_pumpshotgun', 'component_at_ar_flsh')
                        else
                            Notify('~y~Shotgun Unequipped')
                            RemoveWeaponFromPed(PlayerPedId(), 'weapon_pumpshotgun')
                        end
                    else
                        Notify('~r~You Must be in a Police Vehicle to rack/unrack your Shotgun')
                    end
                end
                
                LEOActions.OnListSelect = function(sender, item, index)
                    if item == Spikes then
                        TriggerEvent('SEM_InteractionMenu:Spikes-SpawnSpikes', tonumber(index))
                    elseif item == Props and Config.Props then
                        for _, Prop in pairs(Config.Props) do
                            if Prop.name == item:IndexToItem(index) then
                                if SpawnProp then
                                    SpawnProp(Prop.spawncode, Prop.name)
                                end
                            end
                        end
                    end
                end
                
                RemoveProps.Activated = function(ParentMenu, SelectedItem)
                    if Config.Props and DeleteProp then
                        for _, Prop in pairs(Config.Props) do
                            DeleteProp(Prop.spawncode)
                        end
                    end
                end

            -- Backup menu (unchanged but with error handling)
            if Config.DisplayBackup then
                local LEOBackup = _MenuPool:AddSubMenu(LEOMenu, 'Backup', '', true)
                LEOBackup:SetMenuWidthOffset(Config.MenuWidth)
                    local BK1 = NativeUI.CreateItem('Code 1', 'Call Code 1 Backup to your location')
                    local BK2 = NativeUI.CreateItem('Code 2', 'Call Code 2 Backup to your location')
                    local BK3 = NativeUI.CreateItem('Code 3', 'Call Code 3 Backup to your location')
                    local BK99 = NativeUI.CreateItem('Code 99', 'Call Code 99 Backup to your location')
                    local PanicBTN = NativeUI.CreateItem('~r~Panic Button', 'Officer Panic Button')
                    LEOBackup:AddItem(BK1)
                    LEOBackup:AddItem(BK2)
                    LEOBackup:AddItem(BK3)
                    LEOBackup:AddItem(BK99)
                    LEOBackup:AddItem(PanicBTN)
                    
                    local function CallBackup(code)
                        local Coords = GetEntityCoords(PlayerPedId())
                        local Street1, Street2 = GetStreetNameAtCoord(Coords.x, Coords.y, Coords.z)
                        local StreetName = GetStreetNameFromHashKey(Street1)
                        TriggerServerEvent('SEM_InteractionMenu:Backup', code, StreetName, Coords)
                    end
                    
                    BK1.Activated = function(ParentMenu, SelectedItem) CallBackup(1) end
                    BK2.Activated = function(ParentMenu, SelectedItem) CallBackup(2) end
                    BK3.Activated = function(ParentMenu, SelectedItem) CallBackup(3) end
                    BK99.Activated = function(ParentMenu, SelectedItem) CallBackup(99) end
                    PanicBTN.Activated = function(ParentMenu, SelectedItem) CallBackup('panic') end
            end

            -- Enhanced Stations menu
            if Config.ShowStations and Config.LEOStations then
                local LEOStation = _MenuPool:AddSubMenu(LEOMenu, 'Stations', '', true)
                LEOStation:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Station in pairs(Config.LEOStations) do
                        local StationCategory = _MenuPool:AddSubMenu(LEOStation, Station.name, '', true)
                        StationCategory:SetMenuWidthOffset(Config.MenuWidth)
                            local SetWaypoint = NativeUI.CreateItem('Set Waypoint', 'Set a waypoint to the station')
                            local Teleport = NativeUI.CreateItem('Teleport', 'Teleport to the station')
                            StationCategory:AddItem(SetWaypoint)
                            if Config.AllowStationTeleport then
                                StationCategory:AddItem(Teleport)
                            end
                            SetWaypoint.Activated = function(ParentMenu, SelectedItem)
                                if Station.coords then
                                    SetNewWaypoint(Station.coords.x, Station.coords.y)
                                    Notify('~g~Waypoint set to ' .. Station.name)
                                end
                            end
                            Teleport.Activated = function(ParentMenu, SelectedItem)
                                if Station.coords then
                                    SetEntityCoords(PlayerPedId(), Station.coords.x, Station.coords.y, Station.coords.z)
                                    SetEntityHeading(PlayerPedId(), Station.coords.h or 0.0)
                                    Notify('~g~Teleported to ' .. Station.name)
                                end
                            end
                    end
            end

            -- Enhanced Loadouts menu
            if Config.DisplayLEOUniforms or Config.DisplayLEOLoadouts then
                local LEOLoadouts = _MenuPool:AddSubMenu(LEOMenu, 'Loadouts', '', true)
                LEOLoadouts:SetMenuWidthOffset(Config.MenuWidth)
                    
                    local UniformsList = {}
                    if Config.LEOUniforms then
                        for _, Uniform in pairs(Config.LEOUniforms) do
                            table.insert(UniformsList, Uniform.name)
                        end
                    end
                    
                    local LoadoutsList = {}
                    if Config.LEOLoadouts then
                        for Name, Loadout in pairs(Config.LEOLoadouts) do
                            table.insert(LoadoutsList, Name)
                        end
                    end

                    local Uniforms = NativeUI.CreateListItem('Uniforms', UniformsList, 1, 'Spawn LEO uniforms')
                    local Loadouts = NativeUI.CreateListItem('Loadouts', LoadoutsList, 1, 'Spawn LEO weapon loadouts')
                    if Config.DisplayLEOUniforms and #UniformsList > 0 then
                        LEOLoadouts:AddItem(Uniforms)
                    end
                    if Config.DisplayLEOLoadouts and #LoadoutsList > 0 then
                        LEOLoadouts:AddItem(Loadouts)
                    end
                    
                    LEOLoadouts.OnListSelect = function(sender, item, index)
                        if item == Uniforms and Config.LEOUniforms then
                            for _, Uniform in pairs(Config.LEOUniforms) do
                                if Uniform.name == item:IndexToItem(index) then
                                    if LoadPed then
                                        LoadPed(Uniform.spawncode)
                                        Notify('~b~Uniform Spawned: ~g~' .. Uniform.name)
                                    end
                                end
                            end
                        end

                        if item == Loadouts and Config.LEOLoadouts then
                            for Name, Loadout in pairs(Config.LEOLoadouts) do
                                if Name == item:IndexToItem(index) then
                                    SetEntityHealth(PlayerPedId(), 200)
                                    RemoveAllPedWeapons(PlayerPedId(), true)
                                    AddArmourToPed(PlayerPedId(), 100)

                                    for _, Weapon in pairs(Loadout) do
                                        if GiveWeapon then
                                            GiveWeapon(Weapon.weapon)
                                                                    
                                            for _, Component in pairs(Weapon.components) do
                                                AddWeaponComponent(Weapon.weapon, Component)
                                            end
                                        end
                                    end

                                    Notify('~b~Loadout Spawned: ~g~' .. Name)
                                end
                            end
                        end
                    end
            end

            -- Enhanced Vehicles menu
            if Config.ShowLEOVehicles and Config.LEOVehiclesCategories then
                local LEOVehicles = _MenuPool:AddSubMenu(LEOMenu, 'Vehicles', '', true)
                LEOVehicles:SetMenuWidthOffset(Config.MenuWidth)
                
                for Name, Category in pairs(Config.LEOVehiclesCategories) do
                    local LEOCategory = _MenuPool:AddSubMenu(LEOVehicles, Name, '', true)
                    LEOCategory:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Vehicle in pairs(Category) do
                        local LEOVehicle = NativeUI.CreateItem(Vehicle.name, '')
                        LEOCategory:AddItem(LEOVehicle)
                        if Config.ShowLEOSpawnCode then
                            LEOVehicle:RightLabel(Vehicle.spawncode)
                        end
                        LEOVehicle.Activated = function(ParentMenu, SelectedItem)
                            if SpawnVehicle then
                                SpawnVehicle(Vehicle.spawncode, Vehicle.name, Vehicle.livery, Vehicle.extras)
                            end
                        end
                    end
                end
            end

            -- Enhanced Traffic Manager
            if Config.DisplayTrafficManager then
                local LEOTrafficManager = _MenuPool:AddSubMenu(LEOMenu, 'Traffic Manager', '', true)
                LEOTrafficManager:SetMenuWidthOffset(Config.MenuWidth)
        
                    local TMSize = 10.0
                    local TMSpeed = 0.0
                    local RaduiesNames = {}
                    local Raduies = {
                        {name = '10m', size = 10.0},
                        {name = '20m', size = 20.0},
                        {name = '30m', size = 30.0},
                        {name = '40m', size = 40.0},
                        {name = '50m', size = 50.0},
                        {name = '60m', size = 60.0},
                        {name = '70m', size = 70.0},
                        {name = '80m', size = 80.0},
                        {name = '90m', size = 90.0},
                        {name = '100m', size = 100.0},
                    }
                    local SpeedsNames = {}
                    local Speeds = {
                        {name = '0 mph', speed = 0.0},
                        {name = '5 mph', speed = 5.0},
                        {name = '10 mph', speed = 10.0},
                        {name = '15 mph', speed = 15.0},
                        {name = '20 mph', speed = 20.0},
                        {name = '25 mph', speed = 25.0},
                        {name = '30 mph', speed = 30.0},
                        {name = '40 mph', speed = 40.0},
                        {name = '50 mph', speed = 50.0},
                    }

                    for _, RaduisInfo in pairs(Raduies) do
                        table.insert(RaduiesNames, RaduisInfo.name)
                    end
                    for _, SpeedsInfo in pairs(Speeds) do
                        table.insert(SpeedsNames, SpeedsInfo.name)
                    end
    
                    local Radius = NativeUI.CreateListItem('Radius', RaduiesNames, 1, '')
                    local Speed = NativeUI.CreateListItem('Speed', SpeedsNames, 1, '')
                    local TMCreate = NativeUI.CreateItem('Create Speed Zone', '')
                    local TMDelete = NativeUI.CreateItem('Delete Speed Zone', '')
                    LEOTrafficManager:AddItem(Radius)
                    LEOTrafficManager:AddItem(Speed)
                    LEOTrafficManager:AddItem(TMCreate)
                    LEOTrafficManager:AddItem(TMDelete)
                    
                    Radius.OnListChanged = function(sender, item, index)
                        TMSize = Raduies[index].size
                    end
                    Speed.OnListChanged = function(sender, item, index)
                        TMSpeed = Speeds[index].speed
                    end
                    TMCreate.Activated = function(ParentMenu, SelectedItem)
                        if not Zone then
                            Zone = AddSpeedZoneForCoord(GetEntityCoords(PlayerPedId()), TMSize, TMSpeed, false)
                            Area = AddBlipForRadius(GetEntityCoords(PlayerPedId()), TMSize)
                            SetBlipAlpha(Area, 100)
                            Notify('~g~Speed Zone Created')
                        else
                            Notify('~y~You already have a Speed Zone created')
                        end
                    end
                    TMDelete.Activated = function(ParentMenu, SelectedItem)
                        if Zone then
                            RemoveSpeedZone(Zone)
                            if Area then
                                RemoveBlip(Area)
                            end
                            Zone = nil
                            Area = nil
                            Notify('~r~Speed Zone Deleted')
                        else
                            Notify('~y~You don\'t have a Speed Zone')
                        end
                    end
            end
    end

    -- Enhanced Fire Menu
    if FireRestrict() then
        local FireMenu = _MenuPool:AddSubMenu(MainMenu, '~r~~h~Fire Menu', 'Fire Related Menu', true)
        FireMenu:SetMenuWidthOffset(Config.MenuWidth)
            local FireActions = _MenuPool:AddSubMenu(FireMenu, 'Actions', '', true)
            FireActions:SetMenuWidthOffset(Config.MenuWidth)
                local Drag = NativeUI.CreateItem('~r~Drag', 'Drag/Undrag the closest player')
                local Seat = NativeUI.CreateItem('~r~Seat', 'Place a player in the closest vehicle')
                local Unseat = NativeUI.CreateItem('~r~Unseat', 'Remove a player from the closest vehicle')
                FireActions:AddItem(Drag)
                FireActions:AddItem(Seat)
                FireActions:AddItem(Unseat)
                
                Drag.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Seat.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:SeatNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                Unseat.Activated = function(ParentMenu, SelectedItem)
                    if IsPedInAnyVehicle(PlayerPedId(), true) then
                        Notify('~o~You need to be outside of the vehicle')
                        return
                    end

                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:UnseatNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                -- Enhanced Hospital system
                if Config.FireHospital and Config.HospitalLocation then
                    local HospitalLocations = _MenuPool:AddSubMenu(FireActions, '~r~Hospitalize', '', true)
                    HospitalLocations:SetMenuWidthOffset(Config.MenuWidth)
                        for HospitalName, HospitalInfo in pairs(Config.HospitalLocation) do
                            local Hospitalize = NativeUI.CreateItem(HospitalName, '~r~Hospitalize a player')
                            HospitalLocations:AddItem(Hospitalize)
                            Hospitalize.Activated = function(ParentMenu, SelectedItem)
                                local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                                if PlayerID == nil then
                                    Notify('~r~Please enter a valid player ID')
                                    return
                                end

                                local HospitalTime = EnhancedKeyboardInput('Time: (Seconds) - Max Time: ' .. Config.MaxHospitalTime .. ' | Default Time: 30', 3, "hospitaltime")
                                if HospitalTime == nil then
                                    HospitalTime = 30
                                end

                                Notify('Player Hospitalized for ~b~' .. HospitalTime .. ' seconds')
                                TriggerServerEvent('SEM_InteractionMenu:Hospitalize', PlayerID, HospitalTime, HospitalInfo)
                            end
                        end
                    local Unhospitalize = NativeUI.CreateItem('Unhospitalize', 'Unhospitalize a player')
                    if UnhospitalAllowed then
                        FireActions:AddItem(Unhospitalize)
                    end
                    Unhospitalize.Activated = function(ParentMenu, SelectedItem)
                        local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                        if PlayerID == nil then
                            Notify('~r~Please enter a valid player ID')
                            return
                        end

                        TriggerServerEvent('SEM_InteractionMenu:Unhospitalize', PlayerID)
                        Notify('~g~Unhospitalize request sent for player ID: ' .. PlayerID)
                    end
                end
                
                -- Enhanced Props system
                local PropsList = {}
                if Config.Props then
                    for _, Prop in pairs(Config.Props) do
                        table.insert(PropsList, Prop.name)
                    end
                end
                if #PropsList > 0 then
                    local Props = NativeUI.CreateListItem('Spawn Props', PropsList, 1, 'Spawn props on the ground')
                    local RemoveProps = NativeUI.CreateItem('Remove Props', 'Remove the closest prop')
                    FireActions:AddItem(Props)
                    FireActions:AddItem(RemoveProps)
                    
                    FireActions.OnListSelect = function(sender, item, index)
                        if item == Props and Config.Props then
                            for _, Prop in pairs(Config.Props) do
                                if Prop.name == item:IndexToItem(index) then
                                    if SpawnProp then
                                        SpawnProp(Prop.spawncode, Prop.name)
                                    end
                                end
                            end
                        end
                    end
                    
                    RemoveProps.Activated = function(ParentMenu, SelectedItem)
                        if Config.Props and DeleteProp then
                            for _, Prop in pairs(Config.Props) do
                                DeleteProp(Prop.spawncode)
                            end
                        end
                    end
                end

            -- Fire Stations (enhanced)
            if Config.ShowStations then
                local FireEMSStation = _MenuPool:AddSubMenu(FireMenu, 'Stations', '', true)
                FireEMSStation:SetMenuWidthOffset(Config.MenuWidth)
                    
                    if Config.FireStations then
                        local FireStation = _MenuPool:AddSubMenu(FireEMSStation, 'Fire Stations', '', true)
                        FireStation:SetMenuWidthOffset(Config.MenuWidth)
                            for _, Station in pairs(Config.FireStations) do
                                local StationCategory = _MenuPool:AddSubMenu(FireStation, Station.name, '', true)
                                StationCategory:SetMenuWidthOffset(Config.MenuWidth)
                                    local SetWaypoint = NativeUI.CreateItem('Set Waypoint', 'Set a waypoint to the station')
                                    local Teleport = NativeUI.CreateItem('Teleport', 'Teleport to the station')
                                    StationCategory:AddItem(SetWaypoint)
                                    if Config.AllowStationTeleport then
                                        StationCategory:AddItem(Teleport)
                                    end
                                    SetWaypoint.Activated = function(ParentMenu, SelectedItem)
                                        if Station.coords then
                                            SetNewWaypoint(Station.coords.x, Station.coords.y)
                                            Notify('~g~Waypoint set to ' .. Station.name)
                                        end
                                    end
                                    Teleport.Activated = function(ParentMenu, SelectedItem)
                                        if Station.coords then
                                            SetEntityCoords(PlayerPedId(), Station.coords.x, Station.coords.y, Station.coords.z)
                                            SetEntityHeading(PlayerPedId(), Station.coords.h or 0.0)
                                            Notify('~g~Teleported to ' .. Station.name)
                                        end
                                    end
                            end
                    end

                    if Config.HospitalStations then
                        local EMSStation = _MenuPool:AddSubMenu(FireEMSStation, 'Hospitals', '', true)
                        EMSStation:SetMenuWidthOffset(Config.MenuWidth)
                            for _, Station in pairs(Config.HospitalStations) do
                                local StationCategory = _MenuPool:AddSubMenu(EMSStation, Station.name, '', true)
                                StationCategory:SetMenuWidthOffset(Config.MenuWidth)
                                    local SetWaypoint = NativeUI.CreateItem('Set Waypoint', 'Set a waypoint to the hospital')
                                    local Teleport = NativeUI.CreateItem('Teleport', 'Teleport to the hospital')
                                    StationCategory:AddItem(SetWaypoint)
                                    if Config.AllowStationTeleport then
                                        StationCategory:AddItem(Teleport)
                                    end
                                    SetWaypoint.Activated = function(ParentMenu, SelectedItem)
                                        if Station.coords then
                                            SetNewWaypoint(Station.coords.x, Station.coords.y)
                                            Notify('~g~Waypoint set to ' .. Station.name)
                                        end
                                    end
                                    Teleport.Activated = function(ParentMenu, SelectedItem)
                                        if Station.coords then
                                            SetEntityCoords(PlayerPedId(), Station.coords.x, Station.coords.y, Station.coords.z)
                                            SetEntityHeading(PlayerPedId(), Station.coords.h or 0.0)
                                            Notify('~g~Teleported to ' .. Station.name)
                                        end
                                    end
                            end
                    end
            end

            -- Enhanced Fire Loadouts
            if Config.DisplayFireUniforms or Config.DisplayFireLoadouts then
                local FireLoadouts = _MenuPool:AddSubMenu(FireMenu, 'Loadouts', '', true)
                FireLoadouts:SetMenuWidthOffset(Config.MenuWidth)
                    
                    local UniformsList = {}
                    if Config.FireUniforms then
                        for _, Uniform in pairs(Config.FireUniforms) do
                            table.insert(UniformsList, Uniform.name)
                        end
                    end
                        
                    local LoadoutsList = {
                        'Clear',
                        'Standard',
                    }
                    
                    if #UniformsList > 0 then
                        local Uniforms = NativeUI.CreateListItem('Uniforms', UniformsList, 1, 'Spawn Fire uniforms')
                        if Config.DisplayFireUniforms then
                            FireLoadouts:AddItem(Uniforms)
                        end
                    end
                    
                    local Loadouts = NativeUI.CreateListItem('Loadouts', LoadoutsList, 1, 'Spawns Fire weapon loadouts')
                    if Config.DisplayFireLoadouts then
                        FireLoadouts:AddItem(Loadouts)
                    end
                    
                    FireLoadouts.OnListSelect = function(sender, item, index)
                        if item.Text == 'Uniforms' and Config.FireUniforms then
                            for _, Uniform in pairs(Config.FireUniforms) do
                                if Uniform.name == item:IndexToItem(index) then
                                    if LoadPed then
                                        LoadPed(Uniform.spawncode)
                                        Notify('~b~Uniform Spawned: ~g~' .. Uniform.name)
                                    end
                                end
                            end
                        end
            
                        if item.Text == 'Loadouts' then
                            local SelectedLoadout = item:IndexToItem(index)
                            if SelectedLoadout == 'Clear' then
                                SetEntityHealth(PlayerPedId(), 200)
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                Notify('~r~All Weapons Cleared!')
                            elseif SelectedLoadout == 'Standard' then
                                SetEntityHealth(PlayerPedId(), 200)
                                RemoveAllPedWeapons(PlayerPedId(), true)
                                AddArmourToPed(PlayerPedId(), 100)
                                if GiveWeapon then
                                    GiveWeapon('weapon_flashlight')
                                    GiveWeapon('weapon_fireextinguisher')
                                    GiveWeapon('weapon_flare')
                                    GiveWeapon('weapon_stungun')
                                end
                                Notify('~b~Loadout Spawned: ~g~' .. SelectedLoadout)
                            end
                        end
                    end
            end
            
            -- Enhanced Fire Vehicles
            if Config.ShowFireVehicles and Config.FireVehicles then
                local FireVehicles = _MenuPool:AddSubMenu(FireMenu, 'Vehicles', '', true)
                FireVehicles:SetMenuWidthOffset(Config.MenuWidth)
                
                for _, Vehicle in pairs(Config.FireVehicles) do
                    local FireVehicle = NativeUI.CreateItem(Vehicle.name, '')
                    FireVehicles:AddItem(FireVehicle)
                    if Config.ShowFireSpawnCode then
                        FireVehicle:RightLabel(Vehicle.spawncode)
                    end
                    FireVehicle.Activated = function(ParentMenu, SelectedItem)
                        if SpawnVehicle then
                            SpawnVehicle(Vehicle.spawncode, Vehicle.name, Vehicle.livery, Vehicle.extras)
                        end
                    end
                end
            end
    end

    -- Enhanced Civilian Menu
    if CivRestrict() then
        local CivMenu = _MenuPool:AddSubMenu(MainMenu, '~g~~h~Civilian Menu', 'Civilian Related Menu', true)
        CivMenu:SetMenuWidthOffset(Config.MenuWidth)
            local CivActions = _MenuPool:AddSubMenu(CivMenu, 'Actions', '', true)
            CivActions:SetMenuWidthOffset(Config.MenuWidth)
                local HU = NativeUI.CreateItem('Hands Up', 'Put your hands up')
                local HUK = NativeUI.CreateItem('Hand Up & Kneel', 'Put your hands up and kneel on the ground')
                local Inventory = NativeUI.CreateItem('Inventory', 'Set your inventory')
                local BAC = NativeUI.CreateItem('BAC', 'Set your BAC level')
                local DropWeapon = NativeUI.CreateItem('Drop Weapon', 'Drop your current weapon on the ground')
                CivActions:AddItem(HU)
                CivActions:AddItem(HUK)
                CivActions:AddItem(Inventory)
                CivActions:AddItem(BAC)
                CivActions:AddItem(DropWeapon)
                
                HU.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
                    if DoesEntityExist(Ped) and not isCuffed then
                        Citizen.CreateThread(function()
                            if LoadAnimation then
                                LoadAnimation('random@mugging3')
                            end
                            if IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or isCuffed then
                                ClearPedSecondaryTask(Ped)
                                SetEnableHandcuffs(Ped, false)
                            elseif not IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or not isCuffed then
                                TaskPlayAnim(Ped, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
                                SetEnableHandcuffs(Ped, true)
                            end
                        end)
                    end
                end
                
                HUK.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
                    if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not isCuffed then
                        Citizen.CreateThread(function()
                            if LoadAnimation then
                                LoadAnimation('random@arrests')
                            end
                            if (IsEntityPlayingAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 3)) then
                                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_get_up', 8.0, 1.0, -1, 128, 0, 0, 0, 0)
                            else
                                TaskPlayAnim(Ped, 'random@arrests', 'idle_2_hands_up', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
                                Wait (4000)
                                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
                            end
                        end)
                    end
                end
                
                Inventory.Activated = function(ParentMenu, SelectedItem)
                    local Items = KeyboardInput('Items:', 75)
                    if Items == nil or Items == '' then
                        Notify('~r~No Items Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:InventorySet', Items)
                    Notify('~g~Inventory Set!')
                end
                
                BAC.Activated = function(ParentMenu, SelectedItem)
                    local BACLevel = KeyboardInput('BAC Level - Legal Limit: 0.08', 5)
                    if BACLevel == nil or BACLevel == '' then
                        Notify('~r~No BAC Level Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:BACSet', tonumber(BACLevel))
                    if tonumber(BACLevel) < 0.08 then
                        Notify('~b~BAC Level Set: ~g~' .. tostring(BACLevel))
                    else
                        Notify('~b~BAC Level Set: ~r~' .. tostring(BACLevel))
                    end
                end
                
                DropWeapon.Activated = function(ParentMenu, SelectedItem)
                    local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
                    if CurrentWeapon ~= GetHashKey('weapon_unarmed') then
                        SetCurrentPedWeapon(PlayerPedId(), 'weapon_unarmed', true)
                        SetPedDropsInventoryWeapon(PlayerPedId(), CurrentWeapon, -2.0, 0.0, 0.5, 30)
                        Notify('~r~Weapon Dropped!')
                    else
                        Notify('~r~No weapon to drop!')
                    end
                end
                
            -- Enhanced Civilian Adverts
            if Config.ShowCivAdverts and Config.CivAdverts then
                local CivAdverts = _MenuPool:AddSubMenu(CivMenu, 'Adverts', '', true)
                CivAdverts:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Ad in pairs(Config.CivAdverts) do
                        local Advert  = NativeUI.CreateItem(Ad.name, 'Send an advert for ' .. Ad.name)
                        CivAdverts:AddItem(Advert)
                        Advert.Activated = function(ParentMenu, SelectedItem)
                            local Message = KeyboardInput('Message:', 128)
                            if Message == nil or Message == '' then
                                Notify('~r~No Advert Message Provided!')
                                return
                            end
                
                            TriggerServerEvent('SEM_InteractionMenu:Ads', Message, Ad.name, Ad.loc, Ad.file)
                        end
                    end
            end
            
            -- Enhanced Civilian Vehicles
            if Config.ShowCivVehicles and Config.CivVehicles then
                local CivVehicles = _MenuPool:AddSubMenu(CivMenu, 'Vehicles', '', true)
                CivVehicles:SetMenuWidthOffset(Config.MenuWidth)
                
                for _, Vehicle in pairs(Config.CivVehicles) do
                    local CivVehicle = NativeUI.CreateItem(Vehicle.name, '')
                    CivVehicles:AddItem(CivVehicle)
                    if Config.ShowCivSpawnCode then
                        CivVehicle:RightLabel(Vehicle.spawncode)
                    end
                    CivVehicle.Activated = function(ParentMenu, SelectedItem)
                        if SpawnVehicle then
                            SpawnVehicle(Vehicle.spawncode, Vehicle.name)
                        end
                    end
                end
            end
    end

    -- Enhanced DOT Menu
    if DotRestrict() then
        local DotMenu = _MenuPool:AddSubMenu(MainMenu, '👷 | DOT Menu [WIP / DO NOT USE]', 'DOT Related Menu', true)
        DotMenu:SetMenuWidthOffset(Config.MenuWidth)
            local DotActions = _MenuPool:AddSubMenu(DotMenu, 'Actions', '', true)
            DotActions:SetMenuWidthOffset(Config.MenuWidth)
                local Drag = NativeUI.CreateItem('Drag', 'Drag/Undrag the closest player')
                local HU = NativeUI.CreateItem('Hands Up', 'Put your hands up')
                local HUK = NativeUI.CreateItem('Hand Up & Kneel', 'Put your hands up and kneel on the ground')
                local Inventory = NativeUI.CreateItem('Inventory', 'Set your inventory')
                local BAC = NativeUI.CreateItem('BAC', 'Set your BAC level')
                local DropWeapon = NativeUI.CreateItem('Drop Weapon', 'Drop your current weapon on the ground')
                DotActions:AddItem(HU)
                DotActions:AddItem(Drag)
                DotActions:AddItem(HUK)
                DotActions:AddItem(Inventory)
                DotActions:AddItem(BAC)
                DotActions:AddItem(DropWeapon)
                
                -- DOT actions with enhanced error handling
                Drag.Activated = function(ParentMenu, SelectedItem)
                    local player = GetClosestPlayer()
                    if player and player ~= false and player ~= -1 then
                        TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                    else
                        Notify('~r~No player nearby')
                    end
                end
                
                HU.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
                    if DoesEntityExist(Ped) and not isCuffed then
                        Citizen.CreateThread(function()
                            if LoadAnimation then
                                LoadAnimation('random@mugging3')
                            end
                            if IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or isCuffed then
                                ClearPedSecondaryTask(Ped)
                                SetEnableHandcuffs(Ped, false)
                            elseif not IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or not isCuffed then
                                TaskPlayAnim(Ped, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
                                SetEnableHandcuffs(Ped, true)
                            end
                        end)
                    end
                end
                
                HUK.Activated = function(ParentMenu, SelectedItem)
                    local Ped = PlayerPedId()
                    if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not isCuffed then
                        Citizen.CreateThread(function()
                            if LoadAnimation then
                                LoadAnimation('random@arrests')
                            end
                            if (IsEntityPlayingAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 3)) then
                                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_get_up', 8.0, 1.0, -1, 128, 0, 0, 0, 0)
                            else
                                TaskPlayAnim(Ped, 'random@arrests', 'idle_2_hands_up', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
                                Wait (4000)
                                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
                            end
                        end)
                    end
                end
                
                Inventory.Activated = function(ParentMenu, SelectedItem)
                    local Items = KeyboardInput('Items:', 75)
                    if Items == nil or Items == '' then
                        Notify('~r~No Items Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:InventorySet', Items)
                    Notify('~g~Inventory Set!')
                end
                
                BAC.Activated = function(ParentMenu, SelectedItem)
                    local BACLevel = KeyboardInput('BAC Level - Legal Limit: 0.08', 5)
                    if BACLevel == nil or BACLevel == '' then
                        Notify('~r~No BAC Level Provided!')
                        return
                    end

                    TriggerServerEvent('SEM_InteractionMenu:BACSet', tonumber(BACLevel))
                    if tonumber(BACLevel) < 0.08 then
                        Notify('~b~BAC Level Set: ~g~' .. tostring(BACLevel))
                    else
                        Notify('~b~BAC Level Set: ~r~' .. tostring(BACLevel))
                    end
                end
                
                DropWeapon.Activated = function(ParentMenu, SelectedItem)
                    local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
                    if CurrentWeapon ~= GetHashKey('weapon_unarmed') then
                        SetCurrentPedWeapon(PlayerPedId(), 'weapon_unarmed', true)
                        SetPedDropsInventoryWeapon(PlayerPedId(), CurrentWeapon, -2.0, 0.0, 0.5, 30)
                        Notify('~r~Weapon Dropped!')
                    else
                        Notify('~r~No weapon to drop!')
                    end
                end
                
            -- DOT Adverts
            if Config.ShowCivAdverts and Config.CivAdverts then
                local CivAdverts = _MenuPool:AddSubMenu(DotMenu, 'DOT Advert [WIP]', '', true)
                CivAdverts:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Ad in pairs(Config.CivAdverts) do
                        local Advert  = NativeUI.CreateItem(Ad.name, 'Send an advert for ' .. Ad.name)
                        CivAdverts:AddItem(Advert)
                        Advert.Activated = function(ParentMenu, SelectedItem)
                            local Message = KeyboardInput('Message:', 128)
                            if Message == nil or Message == '' then
                                Notify('~r~No Advert Message Provided!')
                                return
                            end
                
                            TriggerServerEvent('SEM_InteractionMenu:Ads', Message, Ad.name, Ad.loc, Ad.file)
                        end
                    end
            end
            
            -- DOT Vehicles
            if Config.ShowDotVehicles and Config.DotVehicles then
                local DotVehicles = _MenuPool:AddSubMenu(DotMenu, 'Vehicles', '', true)
                DotVehicles:SetMenuWidthOffset(Config.MenuWidth)
            
                for _, Vehicle in pairs(Config.DotVehicles) do
                    local DotVehicle = NativeUI.CreateItem(Vehicle.name, '')
                    DotVehicles:AddItem(DotVehicle)
                    if Config.ShowDotSpawnCode then
                        DotVehicle:RightLabel(Vehicle.spawncode)
                    end
                    DotVehicle.Activated = function(ParentMenu, SelectedItem)
                        if SpawnVehicle then
                            SpawnVehicle(Vehicle.spawncode, Vehicle.name)
                        end
                    end
                end
            end
            
            -- DOT Props
            local PropsList = {}
            if Config.Props then
                for _, Prop in pairs(Config.Props) do
                    table.insert(PropsList, Prop.name)
                end
            end
            
            if #PropsList > 0 then
                local Props = NativeUI.CreateListItem('Spawn Props', PropsList, 1, 'Spawn props on the ground')
                local RemoveProps = NativeUI.CreateItem('Remove Props', 'Remove the closest prop')
                
                DotActions:AddItem(Props)
                DotActions:AddItem(RemoveProps)
                
                DotActions.OnListSelect = function(sender, item, index)
                    if item == Props and Config.Props then
                        for _, Prop in pairs(Config.Props) do
                            if Prop.name == item:IndexToItem(index) then
                                if SpawnProp then
                                    SpawnProp(Prop.spawncode, Prop.name)
                                end
                                break
                            end
                        end
                    end
                end
                
                RemoveProps.Activated = function(ParentMenu, SelectedItem)
                    if Config.Props and DeleteProp then
                        for _, Prop in pairs(Config.Props) do
                            DeleteProp(Prop.spawncode)
                        end
                    end
                end
            end
    end

    -- Enhanced Vehicle Menu
    if VehicleRestrict() then
        local VehicleMenu = _MenuPool:AddSubMenu(MainMenu, '🚘 | Vehicle', 'Vehicle Related Menu', true)
        VehicleMenu:SetMenuWidthOffset(Config.MenuWidth)
            local Seats = {-1, 0, 1, 2}
            local Windows = {'Front', 'Rear', 'All'}
            local Doors = {'Driver', 'Passenger', 'Rear Right', 'Rear Left', 'Hood', 'Trunk', 'All'}
            local Engine = NativeUI.CreateItem('Toggle Engine', 'Toggle your vehicle\'s engine')
            local ILights = NativeUI.CreateItem('Toggle Interior Light', 'Toggle your vehicle\'s interior light')
            local Seat = NativeUI.CreateSliderItem('Change Seats', Seats, 1, 'Switch to a different seat')
            local Window = NativeUI.CreateListItem('Windows', Windows, 1, 'Open/Close your vehicle\'s windows')
            local Door = NativeUI.CreateListItem('Doors', Doors, 1, 'Open/Close your vehicle\'s doors')
            local FixVeh = NativeUI.CreateItem('Repair Vehicle', 'Repair your current vehicle')
            local CleanVeh = NativeUI.CreateItem('Clean Vehicle', 'Clean your current vehicle')
            local DelVeh = NativeUI.CreateItem('~r~Delete Vehicle', 'Delete your current vehicle')
            VehicleMenu:AddItem(Engine)
            VehicleMenu:AddItem(ILights)
            VehicleMenu:AddItem(Seat)
            VehicleMenu:AddItem(Window)
            VehicleMenu:AddItem(Door)
            if Config.VehicleOptions then
                VehicleMenu:AddItem(FixVeh)
                VehicleMenu:AddItem(CleanVeh)
                VehicleMenu:AddItem(DelVeh)
            end
            
            Engine.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if Vehicle ~= nil and Vehicle ~= 0 and GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                    SetVehicleEngineOn(Vehicle, (not GetIsVehicleEngineRunning(Vehicle)), false, true)
                    Notify('~g~Engine Toggled!')
                else
                    Notify('~r~You must be in the driver seat!')
                end
            end
            
            ILights.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if IsPedInVehicle(PlayerPedId(), Vehicle, false) then
                    if IsVehicleInteriorLightOn(Vehicle) then
                        SetVehicleInteriorlight(Vehicle, false)
                    else
                        SetVehicleInteriorlight(Vehicle, true)
                    end
                    Notify('~g~Interior light toggled!')
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
            
            VehicleMenu.OnSliderChange = function(sender, item, index)
                if item == Seat then
                    local VehicleSeat = item:IndexToItem(index)
                    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if Veh ~= 0 then
                        SetPedIntoVehicle(PlayerPedId(), Veh, VehicleSeat)
                    end
                end
            end
            
            VehicleMenu.OnListSelect = function(sender, item, index)
                local Ped = PlayerPedId()
                local Veh = GetVehiclePedIsIn(Ped, false)

                if item == Window then
                    local VehicleWindow = item:IndexToItem(index)
                    if VehicleWindow == 'Front' then
                        if IsPedInAnyVehicle(Ped, false) and GetPedInVehicleSeat(Veh, -1) == Ped then 
                            SetEntityAsMissionEntity(Veh, true, true)
                            if not WindowFrontRolled then
                                RollDownWindow(Veh, 0)
                                RollDownWindow(Veh, 1)
                                WindowFrontRolled = true
                            else
                                RollUpWindow(Veh, 0)
                                RollUpWindow(Veh, 1)
                                WindowFrontRolled = false
                            end
                        end
                    elseif VehicleWindow == 'Rear' then
                        if IsPedInAnyVehicle(Ped, false) and GetPedInVehicleSeat(Veh, -1) == Ped then 
                            SetEntityAsMissionEntity(Veh, true, true)
                            if not WindowRearRolled then
                                RollDownWindow(Veh, 2)
                                RollDownWindow(Veh, 3)
                                WindowRearRolled = true
                            else
                                RollUpWindow(Veh, 2)
                                RollUpWindow(Veh, 3)
                                WindowRearRolled = false
                            end
                        end
                    elseif VehicleWindow == 'All' then
                        if IsPedInAnyVehicle(Ped, false) and GetPedInVehicleSeat(Veh, -1) == Ped then 
                            SetEntityAsMissionEntity(Veh, true, true)
                            if not WindowAllRolled then
                                RollDownWindow(Veh, 0)
                                RollDownWindow(Veh, 1)
                                RollDownWindow(Veh, 2)
                                RollDownWindow(Veh, 3)
                                WindowAllRolled = true
                            else
                                RollUpWindow(Veh, 0)
                                RollUpWindow(Veh, 1)
                                RollUpWindow(Veh, 2)
                                RollUpWindow(Veh, 3)
                                WindowAllRolled = false
                            end
                        end
                    end
                elseif item == Door then
                    local VehicleDoor = item:IndexToItem(index)
                    if VehicleDoor == 'Driver' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 0) > 0 then
                                SetVehicleDoorShut(Veh, 0, false)
                            else
                                SetVehicleDoorOpen(Veh, 0, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Passenger' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 1) > 0 then
                                SetVehicleDoorShut(Veh, 1, false)
                            else
                                SetVehicleDoorOpen(Veh, 1, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Rear Left' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 2) > 0 then
                                SetVehicleDoorShut(Veh, 2, false)
                            else
                                SetVehicleDoorOpen(Veh, 2, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Rear Right' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 3) > 0 then
                                SetVehicleDoorShut(Veh, 3, false)
                            else
                                SetVehicleDoorOpen(Veh, 3, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Hood' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 4) > 0 then
                                SetVehicleDoorShut(Veh, 4, false)
                            else
                                SetVehicleDoorOpen(Veh, 4, false, false)
                            end
                        end
                    elseif VehicleDoor == 'Trunk' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            if GetVehicleDoorAngleRatio(Veh, 5) > 0 then
                                SetVehicleDoorShut(Veh, 5, false)
                            else
                                SetVehicleDoorOpen(Veh, 5, false, false)
                            end
                        end
                    elseif VehicleDoor == 'All' then
                        if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
                            local allOpen = GetVehicleDoorAngleRatio(Veh, 0) > 0
                            if allOpen then
                                SetVehicleDoorShut(Veh, 0, false)
                                SetVehicleDoorShut(Veh, 1, false)
                                SetVehicleDoorShut(Veh, 2, false)
                                SetVehicleDoorShut(Veh, 3, false)
                                SetVehicleDoorShut(Veh, 4, false)
                                SetVehicleDoorShut(Veh, 5, false)
                            else
                                SetVehicleDoorOpen(Veh, 0, false, false)
                                SetVehicleDoorOpen(Veh, 1, false, false)
                                SetVehicleDoorOpen(Veh, 2, false, false)
                                SetVehicleDoorOpen(Veh, 3, false, false)
                                SetVehicleDoorOpen(Veh, 4, false, false)
                                SetVehicleDoorOpen(Veh, 5, false, false)
                            end
                        end
                    end
                end
            end
            
            FixVeh.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if Vehicle ~= nil and Vehicle ~= 0 then
                    SetVehicleEngineHealth(Vehicle, 1000.0)
                    SetVehicleFixed(Vehicle)
                    Notify('~g~Vehicle Repaired!')
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
            
            CleanVeh.Activated = function(ParentMenu, SelectedItem)
                local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if Vehicle ~= nil and Vehicle ~= 0 then
                    SetVehicleDirtLevel(Vehicle, 0.0)
                    Notify('~g~Vehicle Cleaned!')
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
            
            DelVeh.Activated = function(ParentMenu, SelectedItem)
                if IsPedSittingInAnyVehicle(PlayerPedId()) then 
                    local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                    if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then 
                        SetEntityAsMissionEntity(Vehicle, true, true)
                        DeleteVehicle(Vehicle)

                        if not DoesEntityExist(Vehicle) then 
                            Notify('~r~Vehicle Deleted!')
                        else 
                            Notify('~o~Unable to delete vehicle, try again.')
                        end 
                    else 
                        Notify('~r~You must be in the driver\'s seat!')
                    end 
                else
                    Notify('~r~You\'re not in a Vehicle!')
                end
            end
    end

    -- ENHANCED STAFF MENU WITH PROPER COM-BASED SYSTEM
    if StaffRestrict() then
        local StaffMenu = _MenuPool:AddSubMenu(MainMenu, '~r~~h~Staff Menu', 'Staff Related Menu', true)
        StaffMenu:SetMenuWidthOffset(Config.MenuWidth)
            local StaffActions = _MenuPool:AddSubMenu(StaffMenu, 'Actions', '', true)
            StaffActions:SetMenuWidthOffset(Config.MenuWidth)
            local Cuff = NativeUI.CreateItem('Cuff', 'Cuff/Uncuff the closest player')
            local Drag = NativeUI.CreateItem('Drag', 'Drag/Undrag the closest player')
            local Seat = NativeUI.CreateItem('Seat', 'Place a player in the closest vehicle')
            local Unseat = NativeUI.CreateItem('Unseat', 'Remove a player from the closest vehicle')
            local Jail = NativeUI.CreateItem('~r~Staff Jail', 'Enhanced task-based staff jail system')
            local Unjail = NativeUI.CreateItem('Staff UnJail', 'Staff Unjail a Player')
            local clear = NativeUI.CreateItem('World Clear', 'Clear all vehicles')
            StaffActions:AddItem(Cuff)           
            StaffActions:AddItem(Drag)
            StaffActions:AddItem(Seat)
            StaffActions:AddItem(Unseat)
            StaffActions:AddItem(Jail)
            StaffActions:AddItem(Unjail)
            StaffActions:AddItem(clear)
            
            Cuff.Activated = function(ParentMenu, SelectedItem)
                local player = GetClosestPlayer()
                if player and player ~= false and player ~= -1 then
                    TriggerServerEvent('SEM_InteractionMenu:CuffNear', player)
                else
                    Notify('~r~No player nearby')
                end
            end
            
            clear.Activated = function(ParentMenu, SelectedItem)
                ExecuteCommand('delall')
            end
            
            Drag.Activated = function(ParentMenu, SelectedItem)
                local player = GetClosestPlayer()
                if player and player ~= false and player ~= -1 then
                    TriggerServerEvent('SEM_InteractionMenu:DragNear', player)
                else
                    Notify('~r~No player nearby')
                end
            end
            
            Seat.Activated = function(ParentMenu, SelectedItem)
                local player = GetClosestPlayer()
                if player and player ~= false and player ~= -1 then
                    TriggerServerEvent('SEM_InteractionMenu:SeatNear', player)
                else
                    Notify('~r~No player nearby')
                end
            end
            
            Unseat.Activated = function(ParentMenu, SelectedItem)
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    Notify('~o~You need to be outside of the vehicle')
                    return
                end

                local player = GetClosestPlayer()
                if player and player ~= false and player ~= -1 then
                    TriggerServerEvent('SEM_InteractionMenu:UnseatNear', player)
                else
                    Notify('~r~No player nearby')
                end
            end
            
            -- ENHANCED STAFF JAIL ACTIVATION - PURE COM SYSTEM
            Jail.Activated = function(ParentMenu, SelectedItem)
                local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                if PlayerID == nil then
                    Notify('~r~Please enter a valid player ID (1-1000)')
                    return
                end

                -- UPDATED: Only ask for Coms, no time element
                local ComCount = EnhancedKeyboardInput('Coms: (1-50) | Default: 5', 2, "coms")
                if ComCount == nil then
                    ComCount = 5 -- Default coms
                end

                DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 500)
                while UpdateOnscreenKeyboard() == 0 do
                    DisableAllControlActions(0)
                    Wait(0)
                end

                local JailReason = GetOnscreenKeyboardResult()
                if JailReason == nil or JailReason == '' then
                    Notify('~r~Please enter a reason.')
                    return
                end

                -- UPDATED: Show coms and tasks instead of time
                Notify('Player Staff Jailed!\n~b~' .. ComCount .. ' coms~w~ = ~g~' .. ComCount .. ' cleanup tasks~w~\n~r~Must complete ALL tasks for release!\n~w~Reason: ' .. JailReason)
                TriggerServerEvent('SEM_InteractionMenu:StaffJail', PlayerID, ComCount, JailReason)
            end
            
            Unjail.Activated = function(ParentMenu, SelectedItem)
                local PlayerID = EnhancedKeyboardInput('Player ID:', 10, "playerid")
                if PlayerID == nil then
                    Notify('~r~Please enter a valid player ID')
                    return
                end

                TriggerServerEvent('SEM_InteractionMenu:StaffUnjail', PlayerID)
                Notify('~g~Staff unjail request sent for player ID: ' .. PlayerID)
            end

            -- Staff Adverts
            if Config.ShowStaffAdverts and Config.StaffAdverts then
                local StaffAdverts = _MenuPool:AddSubMenu(StaffMenu, 'Adverts', '', true)
                StaffAdverts:SetMenuWidthOffset(Config.MenuWidth)
                    for _, Ad in pairs(Config.StaffAdverts) do
                        local Advert  = NativeUI.CreateItem(Ad.name, 'Send an advert for ' .. Ad.name)
                        StaffAdverts:AddItem(Advert)
                        Advert.Activated = function(ParentMenu, SelectedItem)
                            local Message = KeyboardInput('Message:', 128)
                            if Message == nil or Message == '' then
                                Notify('~r~No Advert Message Provided!')
                                return
                            end
                
                            TriggerServerEvent('SEM_InteractionMenu:Ads', Message, Ad.name, Ad.loc, Ad.file)
                        end
                    end
            end
    end

    -- Enhanced Management Menu
    if ManagementRestrict() then
        local ManagementMenu = _MenuPool:AddSubMenu(MainMenu, '~c~~h~Management Menu', 'Manager Related Menu', true) 
        ManagementMenu:SetMenuWidthOffset(Config.MenuWidth)
        local ManagementActions = _MenuPool:AddSubMenu(ManagementMenu, 'Actions', '', true)
        ManagementActions:SetMenuWidthOffset(Config.MenuWidth)

        local peacetime = NativeUI.CreateItem('Toggle peacetime', 'This toggles peacetime')
        local staffCall = NativeUI.CreateItem('Staff Call', 'Calls all staff to RTO.')

        ManagementActions:AddItem(peacetime)
        ManagementActions:AddItem(staffCall)

        peacetime.Activated = function()
            TriggerServerEvent('peacetime:check')
        end

        staffCall.Activated = function()
            TriggerServerEvent('EasyAdmin:callAllStaff')
        end
    end

    -- Enhanced Emotes Menu
    if EmoteRestrict() then
        local EmotesList = {}
        if Config.EmotesList then
            for _, Emote in pairs(Config.EmotesList) do
                table.insert(EmotesList, Emote.name)
            end
        end

        if #EmotesList > 0 then
            local EmotesMenu = NativeUI.CreateListItem('~y~~h~Emotes', EmotesList, 1, 'General RP Emotes')
            MainMenu:AddItem(EmotesMenu)
                
            MainMenu.OnListSelect = function(sender, item, index)
                if item == EmotesMenu and Config.EmotesList then
                    for _, Emote in pairs(Config.EmotesList) do
                        if Emote.name == item:IndexToItem(index) then
                            if PlayEmote then
                                PlayEmote(Emote.emote, Emote.name)
                            end
                        end
                    end
                end
            end
        end
    end

    _MenuPool:RefreshIndex()
end

-- Enhanced menu control system
local menuOpen = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        _MenuPool:ProcessMenus()    
        _MenuPool:ControlDisablingEnabled(false)
        _MenuPool:MouseControlsEnabled(false)
        
        -- Track menu state
        menuOpen = _MenuPool:IsAnyMenuOpen()
        
        if IsControlJustPressed(1, Config.MenuButton) and GetLastInputMethod(2) then
            if not menuOpen then
                Menu()
                MainMenu:Visible(true)
            else
                _MenuPool:CloseAllMenus()
            end
        end
    end
end)

-- Enhanced command registration
RegisterCommand(Config.Command, function(source, args, rawCommands)
    if Config.OpenMenu == 1 then
        Menu()
        MainMenu:Visible(true)
    end
end)

Citizen.CreateThread(function()
    if Config.OpenMenu == 1 and Config.Command then
        TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Used to open SEM_InteractionMenu')
    end
end)