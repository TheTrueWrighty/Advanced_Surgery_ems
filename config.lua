Config = {}

-- Job restriction (change to what you have your EMS job Set as wether its EMS or Ambulance)
Config.RequiredJob = 'ambulance'

-- Surgery table locations
Config.OperatingTables = {
    vector3(311.2, -567.3, 43.28),
    -- Add more if needed
}

-- Required items
Config.Items = {
    anesthesia = 'anesthesia_kit',
    surgicalkit = 'surgical_kit',
    coagulation = 'coagulation_kit',
    altanesthesia = 'alternative_anesthesia',
    antibiotics = 'antibiotics',
    heartmonitor = 'heart_monitor',
    bonestabilizer = 'bone_stabilizer',
    biopsy = 'biopsy_kit'
}

-- Trauma events (randomly assigned)(can add additional events if you want)
Config.TraumaEvents = {
    { name = 'Infection Risk', item = Config.Items.antibiotics },
    { name = 'Weak Heart', item = Config.Items.heartmonitor },
    { name = 'Fragile Bones', item = Config.Items.bonestabilizer },
    { name = 'Unknown Tumor', item = Config.Items.biopsy },
    { name = 'Gun Shot Wound', item = Config.Items.surgicalkit },
    { name = 'Spinal Injury', item = Config.Items.bonestabilizer },
    { name = 'Mauled by Dog', item = Config.Items.antibiotics },
    { name = 'Hit by a Car', item = Config.Items.heartmonitor }
}

-- Tier-based settings
Config.Tiers = {
    elective = { duration = 30000, difficulty = { 'easy', 'easy' }, xp = 50, bonus = 0 },
    urgent = { duration = 50000, difficulty = { 'easy', 'easy', 'medium' }, xp = 100, bonus = 250 },
    emergency = { duration = 90000, difficulty = { 'medium', 'medium', 'medium' }, xp = 150, bonus = 500 }
}

-- Secondary disease chance (in percent)(can add more disease chance if you want)
Config.SecondaryDiseaseChance = 10
Config.SecondaryDiseases = {
    'Sepsis',
    'Liver Failure',
    'Internal Bleeding',
    'Appendicitis'
}

-- Screenshot upload endpoint(change this to where you want to upload to)
Config.ScreenshotUpload = 'https://your-api.com/upload'