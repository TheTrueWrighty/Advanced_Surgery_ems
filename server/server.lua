local QBCore = exports['qb-core']:GetCoreObject()

-- Check and consume items
RegisterNetEvent('operating:checkItemsAndConsume', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local hasAnesthesia = Player.Functions.GetItemByName('anesthesia_kit')
    local hasSurgicalKit = Player.Functions.GetItemByName('surgical_kit')

    if hasAnesthesia and hasSurgicalKit then
        Player.Functions.RemoveItem('anesthesia_kit', 1)
        Player.Functions.RemoveItem('surgical_kit', 1)
        TriggerClientEvent('operating:itemsChecked', src, true)
    else
        TriggerClientEvent('operating:itemsChecked', src, false)
    end
end)

-- Consent relay
RegisterNetEvent('operating:requestConsentAdvanced', function(target)
    TriggerClientEvent('operating:receiveConsentRequestAdvanced', target, source)
end)

RegisterNetEvent('operating:consentGrantedAdvanced', function(surgeon, patient)
    TriggerClientEvent('operating:consentGrantedAdvanced', surgeon, patient)
end)

-- Log surgery
RegisterServerEvent('operating:logSurgery', function(patientId, result, notes, illness)
    local src = source
    local doctor = QBCore.Functions.GetPlayer(src)
    local patient = QBCore.Functions.GetPlayer(patientId)
    if not doctor or not patient then return end

    exports.oxmysql:insert([[
        INSERT INTO surgery_logs (doctor_cid, doctor_name, patient_cid, patient_name, surgery_result, notes, illness)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], {
        doctor.PlayerData.citizenid,
        doctor.PlayerData.charinfo.firstname .. ' ' .. doctor.PlayerData.charinfo.lastname,
        patient.PlayerData.citizenid,
        patient.PlayerData.charinfo.firstname .. ' ' .. patient.PlayerData.charinfo.lastname,
        result,
        notes,
        illness
    })
end)

-- EMS XP system
RegisterNetEvent('hospital:rewardXP', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData('surgeryxp', (Player.PlayerData.metadata['surgeryxp'] or 0) + amount)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'XP Awarded',
            description = ('You gained %s XP for this surgery.'):format(amount),
            type = 'success'
        })
    end
end)

-- Bonus pay system
RegisterNetEvent('hospital:payBonus', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddMoney('bank', amount, 'surgery-bonus')
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Surgery Bonus',
            description = ('You received a $%s bonus for high-risk surgery.'):format(amount),
            type = 'success'
        })
    end
end)

-- Broadcast EMS alert
RegisterNetEvent('hospital:broadcastAlert', function(message)
    local players = QBCore.Functions.GetPlayers()
    for _, id in ipairs(players) do
        local player = QBCore.Functions.GetPlayer(id)
        if player and player.PlayerData.job.name == 'ambulance' then
            TriggerClientEvent('ox_lib:notify', id, {
                title = 'EMS ALERT',
                description = message,
                type = 'inform'
            })
        end
    end
end)
