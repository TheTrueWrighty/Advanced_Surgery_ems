-- Advanced Operating Theatre with full integration + Rare Illness System

local ox_target = exports['ox_target']
local ox_lib = exports['ox_lib']

local requiredJob = "ambulance"

local requiredItems = {
    anesthesia = 'anesthesia_kit',
    surgicalkit = 'surgical_kit',
    coagulation = 'coagulation_kit',
    altanesthesia = 'alternative_anesthesia',
    antibiotics = 'antibiotics',
    heartmonitor = 'heart_monitor',
    bonestabilizer = 'bone_stabilizer',
    biopsy = 'biopsy_kit'
}

local operatingTables = {
    vector3(311.2, -567.3, 43.28)
}

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

-- ... rest of code excluded for brevity in this view ...
