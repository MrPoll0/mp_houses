Config = {}

Config.AlignMenu = "center" -- this is where the menu is located [left, right, center, top-right, top-left etc.]

Config.CreateTableInDatabase = true -- enable this the first time you start the script, this will create everything in the database.
Config.KeyPrice = 150
Config.Weapons = true -- enable this if you want weapons in the storage.
Config.DirtyMoney = true -- enable this if you want dirty money in the storage.

Config.Debug = false -- enable this only if you know what you're doing.

Config.ActionLabel = {
    ["exit"] = "Salida",
    ["wardrobe"] = "Vestidor",
    ["invite"] = "Invitar"
}

local city = GetConvar("city", "")

if city == "Paleto Bay" then 
Config.LandLord = {
    [1] = {pos = vector3(-300.38, 6329.07, 32.89), data = {name = "Casa normal verde", price = 34000, exception = false}},
    [2] = {pos = vector3(-228.58, 6441.97, 31.2), data = {name = "Casa normal marrón", price = 34000, exception = false}}, 
    [3] = {pos = vector3(-349.01, 6223.02, 31.52), data = {name = "Casa normal roja", price = 22000, exception = false}}, 
    [4] = {pos = vector3(32.55, 6595.1, 32.47), data = {name = "Casa normal naranja", price = 22000, exception = false}}, 
    [5] = {pos = vector3(-49.5, 6361.26, 31.44), data = {name = "Almacén industrial", price = 38000, exception = false}},
    [6] = {pos = vector3(9.13, 6416.0, 31.41), data = {name = "Almacén mediano", price = 28000, exception = false}},
    [7] = {pos = vector3(-193.96, 6266.34, 31.49), data = {name = "Almacén pequeño", price = 20000, exception = false}},
    [8] = {pos = vector3(-419.81,6256.06,30.59), data = {name = "Casa en la playa", price = 400, exception = true}},
}

Config.Houses = {
    [1] = {pos = vector3(-302.44, 6327.16, 32.89), name = "Casa normal verde", 
    exit = vector3(11.29, 6288.56, 27.92), 
    wardrobe = vector3(10.91, 6294.14, 27.92),
    invite = vector3(12.58, 6289.48, 27.92)},

    [2] = {pos = vector3(-229.62, 6445.51, 31.2), name = "Casa normal marrón", 
    exit = vector3(38.98, 6318.89, 28.37), 
    wardrobe = vector3(41.72, 6320.47, 28.37),
    invite = vector3(40.34, 6317.61, 28.37)},

    [3] = {pos = vector3(-347.39, 6225.3, 31.88), name = "Casa normal roja", 
    exit = vector3(27.44, 6302.57, 26.05), 
    wardrobe = vector3(17.71, 6304.58, 28.05),
    invite = vector3(24.14, 6305.92, 28.05)},

    [4] = {pos = vector3(31.19, 6596.68, 32.82), name = "Casa normal naranja", 
    exit = vector3(32.19, 6315.88, 28.47), 
    wardrobe = vector3(25.6, 6313.61, 28.47),
    invite = vector3(32.61, 6314.82, 28.47)},

    [5] = {pos = vector3(-51.72, 6360.45, 31.6), name = "Almacén industrial", 
    exit = vector3(-196.97, 6141.17, 24.74), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(-195.48, 6142.85, 24.74)},

    [6] = {pos = vector3(6.72,6414.11,31.42), name = "Almacén mediano", 
    exit = vector3(11.14, 6457.17, 26.26), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(9.67, 6459.73, 26.26)},

    [7] = {pos = vector3(-195.4, 6264.63, 31.49), name = "Almacén pequeño",
    exit = vector3(28.56, 6472.33, 26.27), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(29.89, 6473.48, 26.27)},

    [8] = {pos = vector3(-437.8,6272.52,30.07), name = "Casa en la playa",
    exit = vector3(173.74, 6391.27, 29.54), 
    wardrobe = vector3(164.72, 6387.21, 28.14),
    invite = vector3(173.14, 6392.79, 29.54)},
}
elseif city == "Los Santos" then 
Config.LandLord = {
    [1] = {pos = vector3(-300.38, 6329.07, 32.89), data = {name = "Casa normal verde", price = 34000, exception = false}},
    [2] = {pos = vector3(-228.58, 6441.97, 31.2), data = {name = "Casa normal marrón", price = 34000, exception = false}}, 
    [3] = {pos = vector3(-349.01, 6223.02, 31.52), data = {name = "Casa normal roja", price = 22000, exception = false}}, 
    [4] = {pos = vector3(32.55, 6595.1, 32.47), data = {name = "Casa normal naranja", price = 22000, exception = false}}, 
    [5] = {pos = vector3(-49.5, 6361.26, 31.44), data = {name = "Almacén industrial", price = 38000, exception = false}},
    [6] = {pos = vector3(9.13, 6416.0, 31.41), data = {name = "Almacén mediano", price = 28000, exception = false}},
    [7] = {pos = vector3(-193.96, 6266.34, 31.49), data = {name = "Almacén pequeño", price = 20000, exception = false}},
    [8] = {pos = vector3(-419.81,6256.06,30.59), data = {name = "Casa en la playa", price = 400, exception = true}},
}

Config.Houses = {
    [1] = {pos = vector3(-302.44, 6327.16, 32.89), name = "Casa normal verde", 
    exit = vector3(11.29, 6288.56, 27.92), 
    wardrobe = vector3(10.91, 6294.14, 27.92),
    invite = vector3(12.58, 6289.48, 27.92)},

    [2] = {pos = vector3(-229.62, 6445.51, 31.2), name = "Casa normal marrón", 
    exit = vector3(38.98, 6318.89, 28.37), 
    wardrobe = vector3(41.72, 6320.47, 28.37),
    invite = vector3(40.34, 6317.61, 28.37)},

    [3] = {pos = vector3(-347.39, 6225.3, 31.88), name = "Casa normal roja", 
    exit = vector3(27.44, 6302.57, 26.05), 
    wardrobe = vector3(17.71, 6304.58, 28.05),
    invite = vector3(24.14, 6305.92, 28.05)},

    [4] = {pos = vector3(31.19, 6596.68, 32.82), name = "Casa normal naranja", 
    exit = vector3(32.19, 6315.88, 28.47), 
    wardrobe = vector3(25.6, 6313.61, 28.47),
    invite = vector3(32.61, 6314.82, 28.47)},

    [5] = {pos = vector3(-51.72, 6360.45, 31.6), name = "Almacén industrial", 
    exit = vector3(-196.97, 6141.17, 24.74), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(-195.48, 6142.85, 24.74)},

    [6] = {pos = vector3(6.72,6414.11,31.42), name = "Almacén mediano", 
    exit = vector3(11.14, 6457.17, 26.26), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(9.67, 6459.73, 26.26)},

    [7] = {pos = vector3(-195.4, 6264.63, 31.49), name = "Almacén pequeño",
    exit = vector3(28.56, 6472.33, 26.27), 
    wardrobe = vector3(0.0, 0.0, 0.0),
    invite = vector3(29.89, 6473.48, 26.27)},

    [8] = {pos = vector3(-437.8,6272.52,30.07), name = "Casa en la playa",
    exit = vector3(173.74, 6391.27, 29.54), 
    wardrobe = vector3(164.72, 6387.21, 28.14),
    invite = vector3(173.14, 6392.79, 29.54)},
}
end

-- This is the keys configuration where we can change the keys we use / add new keys.
Config.Keys = {
    ["ENTER"] = 215,

    ["ARROW LEFT"] = 174,
    ["ARROW RIGHT"] = 175,
    ["ARROW UP"] = 172,
    ["ARROW DOWN"] = 173,

    ["NUMPAD 8"] = 127,
    ["NUMPAD 5"] = 126,

    ["Q"] = 44,
    ["E"] = 38,

    ["G"] = 47,
    ["F"] = 23,

    ["X"] = 73
}

Config.MaxWeight = 100000

Config.localWeight = {
    --- FOOD ---
    bread = 250,
    chocolate = 500,
    cocacola = 500,
    croquettes = 250,
    cupcake = 250,
    hamburger = 250,
    protein_shake = 500,
    sandwich = 250,
    sportlunch = 250,
    
    --- FOOD ---
    
    --- DRINKS ---
    water = 500,
    coffe = 500,
    milk = 500,
    beer = 500,
    tequila = 500,
    vodka = 500,
    whisky = 500,
    wine = 500,
    icetea = 500,
    powerade = 500,
    --- DRINKS ---
    
    --- MEDS ---
    bandage = 100,
    medikit = 500,
    --- MEDS ---
    
    --- JOBS ---
    alive_chicken = 1000,
    clothe = 1000,
    copper = 1000,
    diamond = 1000,
    cutted_wood = 1000,
    essence = 1000,
    fabric = 1000,
    gold = 1000,
    iron = 1000,
    packaged_chicken = 1000,
    packaged_plank = 1000,
    petrol = 1000,
    petrol_raffin = 1000,
    slaughtered_chicken = 1000,
    stone = 1000,
    washed_stone = 1000,
    wood = 1000,
    wool = 1000,
    --- JOBS ---
    
    --- MISC ---
    bulletproof = 2500,
    lighter = 100,
    cigarett = 100,
    gazbottle = 1000,
    scratchoff = 1,
    scratchoff_used = 1,
    gym_membership = 1,
    oxygen_mask = 1000,
    --- MISC ---
    
    --- TOOLS ---
    blowpipe = 1000,
    carokit = 1000,
    carotool = 1000,
    drill = 1000,
    fixkit = 1000,
    fixtool = 1000,
    lockpick = 1000,
    repairkit = 1000,
    --- TOOLS ---
    
    --- ILEGALS ---
    coke = 1000,
    coke_pooch = 1000,
    meth = 1000,
    meth_pooch = 1000,
    opium = 1000,
    opium_pooch = 1000,
    weed = 1000,
    weed_pooch = 1000,
    --- ILEGALS ---
    
    carbon_piece = 500,
    iron_piece = 500,
    gold_piece = 500,
    silver_piece = 500,

    water_25 = 250,
    water_50 = 500,
    fertilizer_25 = 1000,
    fertilizer_50 = 2000,

    blueberry_fruit = 300,
    blueberry_package = 3000,
    blueberry_seed = 50,

    bactery_waterBottle = 300,
    bottleWater_package = 3000,
    full_waterBottle = 300,
    pollution_waterBottle = 300,
    toxic_waterBottle = 300,

    lingot_carbon = 5000,
    lingot_iron = 5000,
    lingot_silver = 5000,
    lingot_gold = 5000,

    pine_wood = 1000,
    pine_processed = 9000,
    

    shovel = 2000,
    weed = 50,
    weed_pooch = 150,

    aditives = 1000,
    coca = 200,
    cocaplant = 500,
    cocaseed = 50,
    cocawithout = 150,
    

    ---WEAPONS----
    clip = 1000,
    WEAPON_GRENADE = 1000,
    WEAPON_BZGAS = 1000,
    WEAPON_SMOKEGRENADE = 1000,
    WEAPON_RAILGUN = 1000,
    WEAPON_STICKYBOMB = 1000,
    WEAPON_KNIFE = 1000,
    WEAPON_NIGHTSTICK = 1000,
    WEAPON_HAMMER = 1000,
    WEAPON_BAT = 1000,
    WEAPON_GOLFCLUB = 1000,
    WEAPON_CROWBAR = 1000,
    WEAPON_PETROLCAN = 1000,
    WEAPON_FIREEXTINGUISHER = 1000,
    WEAPON_BALL = 1000,
    WEAPON_DAGGER = 1000,
    WEAPON_SWEAPON_SNOWBALLTUNGUN = 1000,
    WEAPON_GARBAGEBAG = 1000,
    WEAPON_HANDCUFFS = 1000,
    WEAPON_KNUCKLE = 1000,
    WEAPON_HATCHET = 1000,
    WEAPON_MACHETE = 1000,
    WEAPON_SWITCHBLADE = 1000,
    WEAPON_BATTLEAXE = 1000,
    WEAPON_POOLCUE = 1000,
    WEAPON_FLASHLIGHT = 1000,
    WEAPON_FLAREGUN = 1000,
    WEAPON_PISTOL = 1000,
    WEAPON_COMBATPISTOL = 1000,
    WEAPON_APPISTOL = 1000,
    WEAPON_PISTOL50 = 1000,
    WEAPON_COMBATPDW = 1000,
    WEAPON_MARKSMANPISTOL = 1000,
    WEAPON_SNSPISTOL = 1000,
    WEAPON_HEAVYPISTOL = 1000,
    WEAPON_REVOLVER = 1000,
    WEAPON_VINTAGEPISTOL = 1000,
    WEAPON_STUNGUN = 1000,
    WEAPON_FIREWORK = 1000,
    WEAPON_MINISMG = 1000,
    WEAPON_SMG = 1000,
    WEAPON_MICROSMG = 1000,
    WEAPON_ASSAULTSMG = 1000,
    WEAPON_PUMPSHOTGUN = 1000,
    WEAPON_AUTOSHOTGUN = 1000,
    WEAPON_DBSHOTGUN = 1000,
    WEAPON_ASSAULTSHOTGUN = 1000,
    WEAPON_SAWNOFFSHOTGUN = 1000,
    WEAPON_HEAVYSHOTGUN = 1000,
    WEAPON_MUSKET = 1000,
    WEAPON_COMPACTRIFLE = 1000,
    WEAPON_MARKSMANRIFLE = 1000,
    WEAPON_SPECIALCARBINE = 1000,
    WEAPON_ADVANCEDRIFLE = 1000,
    WEAPON_CARBINERIFLE = 1000,
    WEAPON_ASSAULTRIFLE = 1000,
    WEAPON_BALL = 1000,
    WEAPON_MG = 1000,
    WEAPON_COMBATMG = 1000,
    WEAPON_BULLPUPRIFLE = 1000,
    WEAPON_BULLPUPSHOTGUN = 1000,
    WEAPON_HEAVYSNIPER = 1000,
    WEAPON_SNIPERRIFLE = 1000,
    WEAPON_FLARE = 1000,
    ---WEAPONS----
    
    --- MONEY ---
    black_money = 1,
    bank = 1, 
    --- MONEY ---
}

-- This is the tutorial in the left corner to show how to control the furnishing menu.
Config.HelpTextMessage = "~INPUT_CELLPHONE_LEFT~ ~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_DOWN~ ~INPUT_CELLPHONE_RIGHT~ Mover ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_VEH_SUB_PITCH_UP_ONLY~ / ~INPUT_VEH_SUB_PITCH_DOWN_ONLY~ Altura ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_COVER~ / ~INPUT_CONTEXT~ Rotación ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_DETONATE~ Poner en el suelo ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_SPRINT~ Velocidad ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_ENTER~ Seleccionar mueble ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_FRONTEND_ENDSCREEN_ACCEPT~ Guardar ~n~"
Config.HelpTextMessage = Config.HelpTextMessage .. "~INPUT_VEH_DUCK~ Cancelar y eliminar ~n~"

UUID = function()
    math.randomseed(GetGameTimer() * math.random())

    return math.random(100000, 999999)
end