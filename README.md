# Advanced_Surgery_ems

===============================================
🩺 Advanced Operating Theatre - README
===============================================

📦 OVERVIEW
This is a fully immersive and configurable surgery system for FiveM.
It works independently or alongside standard EMS systems and includes:

- Trauma-based surgery events
- Surgery tier system (elective, urgent, emergency)
- Minigames for complications
- EMS MDT logging with screenshots
- Rare illness and disease mechanics
- XP + bonus pay system
- Configurable through config.lua

🧰 DEPENDENCIES
- qb-core
- ox_target
- ox_lib
- ox_inventory
- screenshot-basic
- (Optional) ems MDT event receiver

🧪 DEV COMMANDS
These can be run in F8 or chat by players with proper job permissions:

- /forceconsent     → simulate a patient accepting surgery
- /forceillness     → instantly trigger a solo surgery event
- /forcesuccess     → give XP & simulate successful outcome
- /forcetrauma [name] → force a trauma event by name (e.g. /forcetrauma Gun Shot Wound)

🎯 EMS INTEGRATION
This version uses `ox_target` to create a surgery option for EMS:

- Appears when near NPCs or global peds
- Only accessible by players with `ambulance` job

You can expand this or bind `TriggerEvent('operating:prepareSurgery')` to your EMS tablet or other menu system.

🗂 FILE STRUCTURE
- client.lua           → surgery logic, trauma flow, effects
- server.lua           → XP, pay, MDT log
- config.lua           → configurable items, trauma list, tiers
- fxmanifest.lua       → FiveM resource declaration

🧾 MDT LOGGING
This script logs:
- Surgery result
- Illness/trauma
- Timestamps
- Screenshot (if supported)
- Tags for search (e.g., "trauma", "gunshot")

🧠 USAGE
1. Ensure all items (e.g., anesthesia_kit, surgical_kit) are added to ox_inventory
2. Place your operating table coords in `Config.OperatingTables`
3. Place the resource in your server's resources folder
4. Add `ensure advanced_surgery_system` to server.cfg
5. Use `/forceconsent` or go near the table to trigger ox_target

🎉 Enjoy one of the most immersive surgery systems ever made for FiveM RP servers.
