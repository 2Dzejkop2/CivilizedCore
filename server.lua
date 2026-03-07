--[[
──────────────────────────────────────────────────────────────────

	SEM_InteractionMenu (server.lua) - Created by Scott M
	Current Version: v1.7.1 (Sep 2021)
	
	Support: https://semdevelopment.com/discord
	
		!!! Change values in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

──────────────────────────────────────────────────────────────────
]]



-- Version Checker
if Config.VersionChecker ~= 2 then
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/ScottMCT/SEM_InteractionMenu/main/version.txt', function(err, text, headers)
        if err == 200 then
            if text ~= resourceVersion then
                if Config.VersionChecker == 0 then
                    print('^3[SEM_InteractionMenu] ^0There is a new version available: ^2' .. text .. '^0 (Current: ^1' .. resourceVersion .. '^0)')
                    print('^3[SEM_InteractionMenu] ^0Download the latest version at: ^2https://semdevelopment.com/discord^0')
                elseif Config.VersionChecker == 1 then
                    print('^3[SEM_InteractionMenu] ^0New version available: ^2' .. text .. '^0')
                end
            end
        end
    end, 'GET', '', {})
end



-- Player data tables
local PlayerInventories = {}
local PlayerBAC = {}
local StaffJailedPlayers = {}
local AdIDCounter = 0



-- Permission Events
RegisterNetEvent('SEM_InteractionMenu:LEOPerms')
AddEventHandler('SEM_InteractionMenu:LEOPerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.leo')
    TriggerClientEvent('SEM_InteractionMenu:LEOPermsResult', src, Allowed)
end)

RegisterNetEvent('SEM_InteractionMenu:FirePerms')
AddEventHandler('SEM_InteractionMenu:FirePerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.fire')
    TriggerClientEvent('SEM_InteractionMenu:FirePermsResult', src, Allowed)
end)

RegisterNetEvent('SEM_InteractionMenu:StaffPerms')
AddEventHandler('SEM_InteractionMenu:StaffPerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.staff')
    TriggerClientEvent('SEM_InteractionMenu:StaffPermsResult', src, Allowed)
end)

RegisterNetEvent('SEM_InteractionMenu:GovPerms')
AddEventHandler('SEM_InteractionMenu:GovPerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.gov')
    TriggerClientEvent('SEM_InteractionMenu:GovPermsResult', src, Allowed)
end)

RegisterNetEvent('SEM_InteractionMenu:UnjailPerms')
AddEventHandler('SEM_InteractionMenu:UnjailPerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.unjail')
    TriggerClientEvent('SEM_InteractionMenu:UnjailPermsResult', src, Allowed)
end)

RegisterNetEvent('SEM_InteractionMenu:UnhospitalPerms')
AddEventHandler('SEM_InteractionMenu:UnhospitalPerms', function()
    local src = source
    local Allowed = IsPlayerAceAllowed(src, 'SEM_InteractionMenu.unhospital')
    TriggerClientEvent('SEM_InteractionMenu:UnhospitalPermsResult', src, Allowed)
end)



-- Interaction relay events (Cuff, Drag, Seat, Unseat)
RegisterNetEvent('SEM_InteractionMenu:CuffNear')
AddEventHandler('SEM_InteractionMenu:CuffNear', function(TargetID)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:Cuff', TargetID)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:DragNear')
AddEventHandler('SEM_InteractionMenu:DragNear', function(TargetID)
    local src = source
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:Drag', TargetID, src)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:SeatNear')
AddEventHandler('SEM_InteractionMenu:SeatNear', function(TargetID)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:Seat', TargetID)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:UnseatNear')
AddEventHandler('SEM_InteractionMenu:UnseatNear', function(TargetID)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:Unseat', TargetID)
    end
end)



-- Jail system
RegisterNetEvent('SEM_InteractionMenu:Jail')
AddEventHandler('SEM_InteractionMenu:Jail', function(TargetID, JailTime, Reason)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:JailPlayer', TargetID, JailTime, Reason)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:Unjail')
AddEventHandler('SEM_InteractionMenu:Unjail', function(TargetID)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:UnjailPlayer', TargetID)
    end
end)



-- Hospitalize system
RegisterNetEvent('SEM_InteractionMenu:Hospitalize')
AddEventHandler('SEM_InteractionMenu:Hospitalize', function(TargetID, HospitalTime, HospitalInfo)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:HospitalizePlayer', TargetID, HospitalTime, HospitalInfo)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:Unhospitalize')
AddEventHandler('SEM_InteractionMenu:Unhospitalize', function(TargetID)
    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:UnhospitalizePlayer', TargetID)
    end
end)



-- Backup system
RegisterNetEvent('SEM_InteractionMenu:Backup')
AddEventHandler('SEM_InteractionMenu:Backup', function(Code, StreetName, Coords)
    TriggerClientEvent('SEM_InteractionMenu:CallBackup', -1, Code, StreetName, Coords)
end)



-- Advertisement system
RegisterNetEvent('SEM_InteractionMenu:Ads')
AddEventHandler('SEM_InteractionMenu:Ads', function(Message, Name, Loc, File)
    AdIDCounter = AdIDCounter + 1
    TriggerClientEvent('SEM_InteractionMenu:SyncAds', -1, Message, Name, Loc, File, AdIDCounter)
end)



-- Inventory system
RegisterNetEvent('SEM_InteractionMenu:InventorySearch')
AddEventHandler('SEM_InteractionMenu:InventorySearch', function(TargetID)
    local src = source
    local Inventory = PlayerInventories[tostring(TargetID)]
    TriggerClientEvent('SEM_InteractionMenu:InventoryResult', src, Inventory)
end)

RegisterNetEvent('SEM_InteractionMenu:InventorySet')
AddEventHandler('SEM_InteractionMenu:InventorySet', function(Items)
    local src = source
    PlayerInventories[tostring(src)] = Items
end)



-- BAC system
RegisterNetEvent('SEM_InteractionMenu:BACTest')
AddEventHandler('SEM_InteractionMenu:BACTest', function(TargetID)
    local src = source
    local BACLevel = PlayerBAC[tostring(TargetID)]
    TriggerClientEvent('SEM_InteractionMenu:BACResult', src, BACLevel)
end)

RegisterNetEvent('SEM_InteractionMenu:BACSet')
AddEventHandler('SEM_InteractionMenu:BACSet', function(BACLevel)
    local src = source
    PlayerBAC[tostring(src)] = BACLevel
end)



-- Global chat
RegisterNetEvent('SEM_InteractionMenu:GlobalChat')
AddEventHandler('SEM_InteractionMenu:GlobalChat', function(Color, Name, Message)
    TriggerClientEvent('chat:addMessage', -1, {
        multiline = true,
        color = Color,
        args = {Name, Message}
    })
end)



-- Staff Jail system
RegisterNetEvent('SEM_InteractionMenu:StaffJail')
AddEventHandler('SEM_InteractionMenu:StaffJail', function(TargetID, ComCount, Reason)
    local src = source
    if GetPlayerName(TargetID) then
        local coms = tonumber(ComCount) or 5
        if coms > Config.StaffMaxComs then
            coms = Config.StaffMaxComs
        end

        StaffJailedPlayers[tostring(TargetID)] = {
            isJailed = true,
            coms = coms,
            reason = Reason,
            completedTasks = 0,
            jailedBy = src
        }

        TriggerClientEvent('SEM_InteractionMenu:StaffJailPlayer', TargetID, coms, Reason)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:StaffUnjail')
AddEventHandler('SEM_InteractionMenu:StaffUnjail', function(TargetID)
    local src = source
    StaffJailedPlayers[tostring(TargetID)] = nil

    if GetPlayerName(TargetID) then
        TriggerClientEvent('SEM_InteractionMenu:StaffUnjailPlayer', TargetID)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:CheckStaffJailStatus')
AddEventHandler('SEM_InteractionMenu:CheckStaffJailStatus', function()
    local src = source
    local jailData = StaffJailedPlayers[tostring(src)]

    if jailData and jailData.isJailed then
        TriggerClientEvent('SEM_InteractionMenu:StaffJailSync', src, true, jailData)
    else
        TriggerClientEvent('SEM_InteractionMenu:StaffJailSync', src, false, nil)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:StaffJailTaskCompleted')
AddEventHandler('SEM_InteractionMenu:StaffJailTaskCompleted', function()
    local src = source
    local jailData = StaffJailedPlayers[tostring(src)]

    if jailData and jailData.isJailed then
        jailData.completedTasks = jailData.completedTasks + 1

        if jailData.completedTasks >= jailData.coms then
            StaffJailedPlayers[tostring(src)] = nil
        end
    end
end)

RegisterNetEvent('SEM_InteractionMenu:StaffJailHelpRequest')
AddEventHandler('SEM_InteractionMenu:StaffJailHelpRequest', function()
    local src = source
    local jailData = StaffJailedPlayers[tostring(src)]

    if jailData and jailData.isJailed then
        print('^3[StaffJail] ^0Player ' .. GetPlayerName(src) .. ' (' .. src .. ') requested help. Progress: ' .. jailData.completedTasks .. '/' .. jailData.coms)
    end
end)



-- Clean up jailed players on disconnect
AddEventHandler('playerDropped', function()
    -- Keep jail data on disconnect so players cannot escape by reconnecting
    -- Data is retained in StaffJailedPlayers table
end)
