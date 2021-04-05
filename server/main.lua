ESX = nil

cachedData = {
    ["houses"] = {},
    ["storages"] = {},
    ["furnishings"] = {},
    ["names"] = {}
}
ownedRoom = nil

TriggerEvent("esx:getSharedObject", function(library) 
    ESX = library 
end)

MySQL.ready(function()
    local sqlTasks = {}

    table.insert(sqlTasks, function(callback)        
        local firstSqlQuery = [[
            SELECT
                userIdentifier, houseData
            FROM
                mp_houses
        ]]

        MySQL.Async.fetchAll(firstSqlQuery, {
            
        }, function(response)
            for houseIndex, houseData in ipairs(response) do
                for k,v in pairs(houseData) do 
                    if k == "houseData" then 
                        local decodedData = json.decode(v)
            
                        if not cachedData["houses"][decodedData["room"]] then
                            cachedData["houses"][decodedData["room"]] = {}
                            cachedData["houses"][decodedData["room"]]["rooms"] = {}
                        end
            
                        table.insert(cachedData["houses"][decodedData["room"]]["rooms"], {
                            ["motelData"] = decodedData
                        })
                    end
                end
            end
            
            callback(true)
        end)
    end)

    table.insert(sqlTasks, function(callback)  
        local secondSqlQuery = [[
            SELECT
                storageId, storageData
            FROM
                mp_houses_storages
        ]]
        
        MySQL.Async.fetchAll(secondSqlQuery, {
            
        }, function(response)
            for storageIndex, storageData in ipairs(response) do
                local decodedData = json.decode(storageData["storageData"])

                if not cachedData["storages"][storageData["storageId"]] then
                    cachedData["storages"][storageData["storageId"]] = {}
                    cachedData["storages"][storageData["storageId"]]["items"] = {}
                end

                cachedData["storages"][storageData["storageId"]] = decodedData
            end

            callback(true)
        end)
    end)

    table.insert(sqlTasks, function(callback)    
        local thirdSqlQuery = [[
            SELECT
                owner, houseId, furnishingData
            FROM
                mp_houses_furnishings
        ]]

        MySQL.Async.fetchAll(thirdSqlQuery, {
            
        }, function(response)
            for furnishingIndex, furnishingData in ipairs(response) do
                local decodedFurnishingData = json.decode(furnishingData["furnishingData"] or "{}")
                if not cachedData["furnishings"][furnishingData["houseId"]] then 
                    cachedData["furnishings"][furnishingData["houseId"]] = {}
                end
                if not cachedData["furnishings"][furnishingData["houseId"]]["furnishing"] then 
                    cachedData["furnishings"][furnishingData["houseId"]]["furnishing"] = {}
                end
                cachedData["furnishings"][furnishingData["houseId"]]["furnishing"] = decodedFurnishingData
            end

            callback(true)
        end)
    end)

    table.insert(sqlTasks, function(callback)    
        local fourthSqlQuery = [[
            SELECT
                owner, ownedFurnishingData
            FROM
                mp_houses_ownedfurnishing
        ]]

        MySQL.Async.fetchAll(fourthSqlQuery, {
            
        }, function(response)
            for furnishingIndex, furnishingData in ipairs(response) do
                local decodedOwnedFurnishingData = json.decode(furnishingData["ownedFurnishingData"])
                if not cachedData["furnishings"][furnishingData["owner"]] then 
                    cachedData["furnishings"][furnishingData["owner"]] = {}
                end
                if not cachedData["furnishings"][furnishingData["owner"]]["ownedFurnishing"] then 
                    cachedData["furnishings"][furnishingData["owner"]]["ownedFurnishing"] = {}
                end
                cachedData["furnishings"][furnishingData["owner"]]["ownedFurnishing"] = decodedOwnedFurnishingData
            end

            callback(true)
        end)
    end)

    Async.parallel(sqlTasks, function(responses)
        ESX.Trace("SQL Tasks finished.")
    end)
end)

RegisterServerEvent("james_motels:globalEvent")
AddEventHandler("james_motels:globalEvent", function(options)
    TriggerClientEvent("james_motels:eventHandler", -1, options["event"] or "none", options["data"] or nil)
end)

ESX.RegisterServerCallback("james_motels:fetchMotels", function(source, callback)
    local player = ESX.GetPlayerFromId(source)

    if player then
        local sqlQuery = [[
            SELECT
                keyData
            FROM
                mp_houses_keys
            WHERE
                owner = @owner
        ]]

        MySQL.Async.fetchAll(sqlQuery, {
            ["@owner"] = player["identifier"]
        }, function(response)
            local playerKeys = {}

            for keyIndex, keyData in ipairs(response) do
                local decodedData = json.decode(keyData["keyData"])

                table.insert(playerKeys, decodedData)
            end

            GetCharacterName(player, function(playerName)
                callback(cachedData["houses"], cachedData["storages"], cachedData["furnishings"], playerKeys, playerName)
            end)
        end)
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("james_motels:addItemToStorage", function(source, callback, newTable, newItem, storageId)
    local player = ESX.GetPlayerFromId(source)

    if player then
        cachedData["storages"][storageId] = newTable

        if newItem["type"] == "item" then
            player.removeInventoryItem(newItem["name"], newItem["count"])
        elseif newItem["type"] == "weapon" then
            player.removeWeapon(newItem["name"], newItem["count"])
        elseif newItem["type"] == "black_money" then
            player.removeAccountMoney("black_money", newItem["count"])
        end

        TriggerClientEvent("james_motels:eventHandler", -1, "update_storages", {
            ["newTable"] = newTable,
            ["storageId"] = storageId
        })

        UpdateStorageDatabase(storageId, newTable)

        callback(true)
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("james_motels:takeItemFromStorage", function(source, callback, newTable, newItem, storageId)
    local player = ESX.GetPlayerFromId(source)

    if player then
        cachedData["storages"][storageId] = newTable

        if newItem["type"] == "item" then
            player.addInventoryItem(newItem["name"], newItem["count"])
        elseif newItem["type"] == "weapon" then
            player.addWeapon(newItem["name"], newItem["count"])
        elseif newItem["type"] == "black_money" then
            player.addAccountMoney("black_money", newItem["count"])
        end

        TriggerClientEvent("james_motels:eventHandler", -1, "update_storages", {
            ["newTable"] = newTable,
            ["storageId"] = storageId
        })

        UpdateStorageDatabase(storageId, newTable)

        callback(true)
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("james_motels:retreivePlayers", function(source, callback, playersSent)
    local player = ESX.GetPlayerFromId(source)

    --[[ 
    if #playersSent <= 0 then
        callback(false)

        return
    end
    ]]

    if player then
        local newPlayers = {}
        local target = ESX.GetPlayerFromId(playersSent)

        local characterNames = cachedData["names"][target["source"]]

        if target then
            if target["source"] ~= source then
                table.insert(newPlayers, {
                    ["firstname"] = characterNames["firstname"],
                    ["lastname"] = characterNames["lastname"],
                    ["source"] = target["source"]
                })
            end
        end

        callback(newPlayers)
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("mp_houses:buyHouse", function(source, callback, room)
    local player = ESX.GetPlayerFromId(source)

    if player then
        if room.exception then
            if player.getAccount('arkoins').money >= room.price then 
                player.removeAccountMoney('arkoins', room.price)
            else
                return callback(false)
            end

            CreateMotel(source, room.name, function(confirmed, uuid)
                if confirmed then
                    callback(true, uuid)
                else
                    callback(false)
                end
            end)
        else
            if player.getMoney() >= room.price then
                player.removeMoney(room.price)
            elseif player.getAccount("bank")["money"] >= room.price then
                player.removeAccountMoney("bank", room.price)
            else
                return callback(false)
            end

            CreateMotel(source, room.name, function(confirmed, uuid)
                if confirmed then
                    callback(true, uuid)
                else
                    callback(false)
                end
            end)
        end
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("james_motels:getPlayerDressing", function(source, cb)
    local player = ESX.GetPlayerFromId(source)
  
    TriggerEvent("esx_datastore:getDataStore", "property", player["identifier"], function(store)
        local count = store.count("dressing")

        local labels = {}
  
        for index = 1, count do
            local entry = store.get("dressing", index)

            table.insert(labels, entry["label"])
        end
  
        cb(labels)
    end)
end)
  
ESX.RegisterServerCallback("james_motels:getPlayerOutfit", function(source, cb, num)
    local player = ESX.GetPlayerFromId(source)

    TriggerEvent("esx_datastore:getDataStore", "property", player["identifier"], function(store)
        local outfit = store.get("dressing", num)

        cb(outfit["skin"])
    end)
end)

ESX.RegisterServerCallback("james_motels:saveFurnishing", function(source, callback, houseId, furnishingData, ownedFurnishingData)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    local sqlQuery = [[
        INSERT
            INTO
        mp_houses_furnishings
            (houseId, owner, furnishingData)
        VALUES
            (@houseId, @owner, @data)
        ON DUPLICATE KEY UPDATE
            furnishingData = @data
    ]]

    local sqlQuery2 = [[
        UPDATE
        mp_houses_ownedfurnishing
        SET ownedFurnishingData = @ownedFurnishingData
        WHERE
            owner = @owner
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@houseId"] = houseId, 
        ["@owner"] = player.identifier,
        ["@data"] = json.encode(furnishingData),
    }, function(rowsChanged)
        if rowsChanged > 0 then
            MySQL.Async.execute(sqlQuery2, {
                ["@owner"] = player.identifier,
                ["@ownedFurnishingData"] = json.encode(ownedFurnishingData)
            }, function(rowsChanged2)
                if rowsChanged2 > 0 then
                    if not cachedData["furnishings"][houseId] then
                        cachedData["furnishings"][houseId] = {}
                    end

                    if not cachedData["furnishings"][houseId]["furnishing"] then
                        cachedData["furnishings"][houseId]["furnishing"] = {}
                    end
                        
                    cachedData["furnishings"][houseId]["furnishing"] = furnishingData
                    cachedData["furnishings"][player.identifier]["ownedFurnishing"] = ownedFurnishingData

                    callback(true)
                else
                    callback(false)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback("james_motels:checkMoney", function(source, callback)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    if player.getMoney() >= Config.KeyPrice then
        player.removeMoney(Config.KeyPrice)

        callback(true)
    elseif player.getAccount("bank")["money"] >= Config.KeyPrice then
        player.removeAccountMoney("bank", Config.KeyPrice)
        
        callback(true)
    else
        callback(false)
    end
end)

ESX.RegisterServerCallback("mp_houses:sellHouse", function(source, callback, houseData)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    local removeSqlTasks = {}

    table.insert(removeSqlTasks, function(callback)        
        local sqlQuery = [[
            DELETE
                FROM
            mp_houses
                WHERE
            houseId = @houseId
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@houseId"] = houseData["uniqueId"]
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)

    table.insert(removeSqlTasks, function(callback)        
        local sqlQuery = [[
            DELETE
                FROM
            mp_houses_storages
                WHERE
            storageId = @motelId
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@motelId"] = "house-" .. houseData["uniqueId"]
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)

    table.insert(removeSqlTasks, function(callback)        
        local sqlQuery = [[
            DELETE
                FROM
            mp_houses_furnishings
                WHERE
            houseId = @houseId
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@houseId"] = houseData["uniqueId"]
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)

    table.insert(removeSqlTasks, function(callback)        
        local sqlQuery = 'DELETE FROM mp_houses_keys WHERE keyData LIKE "%' .. houseData["uniqueId"] .. '%"'
        
        MySQL.Async.execute(sqlQuery, {
            
        }, function(rowsChanged)
            if rowsChanged > 0 then
                callback(true)
            else
                callback(false)
            end
        end)
    end)

    Async.parallel(removeSqlTasks, function(responses)
        if #responses == 4 then
            ESX.Trace("House successfully deleted on: " .. player["name"])

            local soldName
            local moneyG
            local pass 

            for roomIndex, roomData in ipairs(cachedData["houses"][houseData["room"]]["rooms"]) do
                if roomData["motelData"]["uniqueId"] == houseData["uniqueId"] then
                    for k,v in pairs(Config.LandLord) do 
                        for a,b in pairs(v) do
                            if a == "data" then
                                for m,n in pairs(b) do
                                    if m == "name" then 
                                        if n == houseData["room"] then 
                                            soldName = n
                                        end
                                    end
                                end
                            end
                        end
                    end
                    table.remove(cachedData["houses"][houseData["room"]]["rooms"], roomIndex)

                    TriggerClientEvent("james_motels:eventHandler", -1, "update_motels", cachedData["houses"])

                    break
                end
            end

            --[[ 
            for k,v in pairs(Config.LandLord) do 
                for a,b in pairs(v) do 
                    if a == "name" then 
                        if b == soldName then
                            pass[soldName] = true 
                        end 
                    end

                    if a == "price" then 
                        if pass[soldName] == true then
                            moneyG = b 
                            print(moneyG)
                        end
                    end
                end
            end
            ]]

            player.addMoney(100)

            callback(true)
        else
            ESX.Trace("House deletion failed on: " .. player["name"])

            callback(false)
        end
    end)
end)

ESX.RegisterServerCallback("james_motels:purchaseFurnishing", function(source, callback, furnishingData)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    if player.getMoney() >= furnishingData["price"] then
        player.removeMoney(furnishingData["price"])
    elseif player.getAccount("bank")["money"] >= furnishingData["price"] then
        player.removeAccountMoney("bank", furnishingData["price"])
    else
        return callback(false)
    end

    local identifier = player.identifier

    if not cachedData["furnishings"][identifier] then
        cachedData["furnishings"][identifier] = {}
    end

    if not cachedData["furnishings"][identifier]["ownedFurnishing"] then
        cachedData["furnishings"][identifier]["ownedFurnishing"] = {}
    end

    furnishingData["coords"] = nil
    furnishingData["rotation"] = nil

    table.insert(cachedData["furnishings"][identifier]["ownedFurnishing"], furnishingData)

    local sqlQuery = [[
        INSERT
            INTO
        mp_houses_ownedfurnishing
            (owner, ownedFurnishingData)
        VALUES
            (@owner, @data)
        ON DUPLICATE KEY UPDATE
            ownedFurnishingData = @data
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@owner"] = player.identifier,
        ["@data"] = json.encode(cachedData["furnishings"][identifier]["ownedFurnishing"])
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("james_motels:eventHandler", -1, "update_owned_furnishing", {
                ["newData"] = cachedData["furnishings"][identifier]["ownedFurnishing"]
            })

            callback(true)
        else
            callback(false)
        end
    end)
end)

ESX.RegisterServerCallback("mp_houses:getIdentifier", function(source, callback)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end
    callback(player.identifier)
end)