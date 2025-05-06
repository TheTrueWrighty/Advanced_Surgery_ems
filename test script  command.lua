-- Add to a temporary client command file or test script:
RegisterCommand("testsurgery", function()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    SetEntityCoords(player, 311.2, -567.3, 43.28) -- Teleport to table
    Wait(1000)
    TriggerEvent("operating:prepareSurgery")
end)
Open console or chat and run: /testsurgery
(Assumes your player is set as ambulance job and has the required items in inventory.)

 if solo testing use this

 -- Developer command to simulate solo surgery without needing a second player (delete force commands after testing)

RegisterCommand("forcetrauma", function(source, args)
    local traumaName = table.concat(args, " ")
    for _, case in ipairs(Config.TraumaEvents) do
        if string.lower(case.name) == string.lower(traumaName) then
            TriggerEvent('ox_lib:notify', {
                title = 'Forced Trauma Test',
                description = 'Forcing trauma: ' .. case.name,
                type = 'inform'
            })
            TriggerEvent('operating:consentGrantedAdvanced', GetPlayerServerId(PlayerId()))
            return
        end
    end
    TriggerEvent('ox_lib:notify', {
        title = 'Trauma Not Found',
        description = traumaName .. ' does not match any defined trauma events.',
        type = 'error'
    })
end)
RegisterCommand("forceillness", function()
    local playerId = PlayerId()
    TriggerEvent('operating:consentGrantedAdvanced', GetPlayerServerId(playerId))
end)

RegisterCommand("forcesuccess", function()
    local playerId = PlayerId()
    local dummyEvent = {
        name = 'Test Condition',
        item = 'surgical_kit'
    }
    local chosenEvent = dummyEvent
    TriggerServerEvent('hospital:rewardXP', 999)
    TriggerEvent('ox_lib:notify', { title = 'DEBUG', description = 'Forced successful surgery with test trauma.', type = 'success' })
end)


RegisterCommand("forceconsent", function()
    local playerId = PlayerId()
    TriggerEvent('operating:consentGrantedAdvanced', GetPlayerServerId(playerId))
end)