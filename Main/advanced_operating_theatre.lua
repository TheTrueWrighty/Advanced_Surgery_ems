-- Advanced Operating Theatre with full integration + Rare Illness System

-- Load shared config
Config = require 'config'

local ox_target = exports['ox_target']
local ox_lib = exports['ox_lib']

local requiredJob = Config.RequiredJob

local requiredItems = Config.Items

local operatingTables = Config.OperatingTables

-- Setup target zones
CreateThread(function()
    for _, coords in pairs(operatingTables) do
        exports['ox_target']:addBoxZone({
            coords = coords,
            size = vec3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'start_advanced_surgery',
                    icon = 'fas fa-heartbeat',
                    label = 'Start Advanced Surgery',
                    onSelect = function()
                        TriggerEvent('operating:prepareSurgery')
                    end
                },
                {
                    name = 'view_health_chart',
                    icon = 'fas fa-notes-medical',
                    label = 'View Patient Health Chart',
                    onSelect = function()
                        TriggerServerEvent('operating:viewHealthChart')
                    end
                }
            }
        })
    end
end)

RegisterNetEvent('operating:prepareSurgery', function()
    local playerPed = PlayerPedId()
    local job = exports['qb-core']:GetPlayerData().job.name

    if job ~= requiredJob then
        ox_lib:notify({ title = 'Operating Theatre', description = 'Only doctors can perform surgeries.', type = 'error' })
        return
    end

    TriggerServerEvent('operating:checkItemsAndConsume')
end)

RegisterNetEvent('operating:itemsChecked', function(success)
    if not success then
        ox_lib:notify({ title = 'Operating Theatre', description = 'Missing surgical items!', type = 'error' })
        return
    end

    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
        ox_lib:notify({ title = 'Operating Theatre', description = 'No patient nearby.', type = 'error' })
        return
    end

    TriggerServerEvent('operating:requestConsentAdvanced', GetPlayerServerId(closestPlayer))
end)

RegisterNetEvent('operating:receiveConsentRequestAdvanced', function(surgeon)
    local input = lib.inputDialog('Surgery Consent', {
        { type = 'checkbox', label = 'Do you consent to surgery?', default = false }
    })

    if input and input[1] == true then
        TriggerServerEvent('operating:consentGrantedAdvanced', surgeon, GetPlayerServerId(PlayerId()))
    else
        ox_lib:notify({ title = 'Surgery', description = 'You refused surgery.', type = 'error' })
    end
end)

RegisterNetEvent('operating:consentGrantedAdvanced', function(patient)
    local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(patient))

    lib.progressCircle({ duration = 8000, position = 'bottom', label = 'Applying Anesthesia...', disable = { move = true, car = true, combat = true } })
    Wait(8000)
    FreezeEntityPosition(targetPed, true)
    TaskPlayAnim(targetPed, "anim@gangops@morgue@table@", "body_search", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Randomly assign a surgery tier
    local tierOptions = {'elective', 'urgent', 'emergency'}
    local tier = tierOptions[math.random(1, #tierOptions)]
    ox_lib:notify({ title = 'Surgery Tier Assigned', description = 'Tier: ' .. tier, type = 'inform' })

    

    local eventCases = Config.TraumaEvents,
        { name = 'Fragile Bones', item = requiredItems.bonestabilizer },
        { name = 'Unknown Tumor', item = requiredItems.biopsy },
        { name = 'Gun Shot Wound', item = requiredItems.surgicalkit },
        { name = 'Spinal Injury', item = requiredItems.bonestabilizer },
        { name = 'Mauled by Dog', item = requiredItems.antibiotics },
        { name = 'Hit by a Car', item = requiredItems.heartmonitor }
    },
        { name = 'Spinal Injury', item = requiredItems.bonestabilizer },
        { name = 'Mauled by Dog', item = requiredItems.antibiotics },
        { name = 'Hit by a Car', item = requiredItems.heartmonitor }
    }

    local chosenEvent = eventCases[math.random(1, #eventCases)]

    -- Apply trauma-based visuals
    if chosenEvent.name == 'Gun Shot Wound' then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
        StartScreenEffect('RedMist', 3000, false)
    elseif chosenEvent.name == 'Spinal Injury' then
        RequestAnimSet("move_m@injured")
        while not HasAnimSetLoaded("move_m@injured") do Wait(0) end
        SetPedMovementClipset(PlayerPedId(), "move_m@injured", 1.0)
    elseif chosenEvent.name == 'Mauled by Dog' then
        StartScreenEffect('Wobbly', 3000, false)
    elseif chosenEvent.name == 'Hit by a Car' then
        ShakeGameplayCam('ROAD_VIBRATION_SHAKE', 0.6)
    end

    local consent = lib.inputDialog('Patient Trauma Detected', {
        { type = 'checkbox', label = 'Acknowledge and prepare for ' .. chosenEvent.name, default = false }
    })

    if not consent or not consent[1] then
        TriggerEvent('ox_lib:notify', { title = 'Operation Halted', description = 'You must acknowledge the trauma before proceeding.', type = 'error' })
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(targetPed, false)
        ResetPedMovementClipset(PlayerPedId(), 0.0)
        return
    end

    local hasItem = exports.ox_inventory:Search('count', chosenEvent.item) > 0
    if not hasItem then
        TriggerEvent('ox_lib:notify', { title = 'Complication!', description = chosenEvent.name .. ' requires treatment item!', type = 'error' })
        ApplyDamageToPed(targetPed, 75, false)
        SetPedToRagdoll(targetPed, 5000, 5000, 0, true, true, false)
        TriggerServerEvent('operating:logSurgery', patient, 'Failed (Untreated Trauma)', 'Trauma untreated: ' .. chosenEvent.name, chosenEvent.name)
        ResetPedMovementClipset(PlayerPedId(), 0.0)
        return
    end

    local tierTimes = {
        elective = 12000,
        urgent = 15000,
        emergency = 18000
    }

    lib.progressCircle({ duration = tierTimes[tier], position = 'bottom', label = 'Performing Surgery...', disable = { move = true, car = true, combat = true } })

    -- Optional: simulate camera capture
    exports['screenshot-basic']:requestScreenshotUpload('https://your-api.com/upload', 'files[]', function(data)
        local resultData = json.decode(data)
        if resultData and resultData.files and resultData.files[1] then
            notes = notes .. '
Photo Log: ' .. resultData.files[1].url
        end
    end, 'image/png')

    -- Disease roll
    local diseases = { 'Sepsis', 'Liver Failure', 'Internal Bleeding', 'Appendicitis' }
    if math.random(1, 100) <= 20 then
        local randomDisease = diseases[math.random(1, #diseases)]
        illness = illness .. ' + ' .. randomDisease
        notes = notes .. '
Secondary diagnosis: ' .. randomDisease
    end
    local difficulties = {
        elective = {'easy', 'easy'},
        urgent = {'easy', 'medium', 'medium'},
        emergency = {'medium', 'hard', 'hard'}
    }

    local complication = math.random(1, 100)
    local result = 'Success'
    local notes = 'Standard surgical procedure. Tier: ' .. tier
    local illness = chosenEvent and chosenEvent.name or 'None'

    if complication <= 10 then
        local inputSuccess = lib.skillCheck(difficulties[tier], {'w', 'a', 's', 'd'})
        if not inputSuccess then
            ApplyDamageToPed(targetPed, 50, false)
            SetPedToRagdoll(targetPed, 5000, 5000, 0, true, true, false)
            result = 'Failed (Complications)'
            notes = 'Surgery failed due to complication and skillcheck failure.'
            TriggerEvent('ox_lib:notify', { title = 'Surgery', description = 'Surgery failed! Patient went into shock.', type = 'error' })
        else
            result = 'Success (With Complication)'
            notes = 'Complication occurred, but surgery completed.'
            TriggerEvent('ox_lib:notify', { title = 'Surgery', description = 'Surgery completed despite difficulties.', type = 'success' })
        end
    else
        TriggerEvent('ox_lib:notify', { title = 'Surgery', description = 'Surgery completed successfully.', type = 'success' })
    end

    Wait(5000)
    ClearPedTasks(playerPed)
    ClearPedTasks(targetPed)
    FreezeEntityPosition(targetPed, false)

    lib.alertDialog({
        header = 'Surgery Summary',
        content = ('Patient: %s
Result: %s
Illness: %s
Notes: %s'):format(GetPlayerName(GetPlayerFromServerId(patient)), result, illness, notes),
        centered = true
    })

    -- Bonus reward system based on tier
    if tier == 'elective' then
        TriggerServerEvent('hospital:rewardXP', 50)
    elseif tier == 'urgent' then
        TriggerServerEvent('hospital:rewardXP', 100)
        TriggerServerEvent('hospital:payBonus', 250)
    elseif tier == 'emergency' then
        TriggerServerEvent('hospital:rewardXP', 150)
        TriggerServerEvent('hospital:payBonus', 500)
        TriggerServerEvent('hospital:broadcastAlert', '**EMERGENCY SURGERY IN PROGRESS**')
    end

    TriggerServerEvent('operating:logSurgery', patient, result, notes, illness)
    TriggerServerEvent('mdt:addMedicalNote', GetPlayerServerId(patient), json.encode({
        title = illness,
        summary = 'Treated during surgery with result: ' .. result,
        tags = {'surgery', string.lower(illness:gsub(' ', '_')), 'trauma'},
        notes = notes
    }))
end)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local plyCoords = GetEntityCoords(PlayerPedId())

    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            local targetCoords = GetEntityCoords(GetPlayerPed(player))
            local distance = #(targetCoords - plyCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end
