CreateMotel = function(source, motelRoom, callback)
    local player = ESX.GetPlayerFromId(source)

    local characterNames = cachedData["names"][player["source"]]

    if player then
        local motelData = {
            ["displayLabel"] = characterNames["firstname"] .. " " .. characterNames["lastname"],
            ["owner"] = player["identifier"],
            ["room"] = motelRoom,
            ["uniqueId"] = UUID()
        }

        local sqlQuery = [[
            INSERT
                INTO
            mp_houses
                (userIdentifier, houseId, houseData)
            VALUES
                (@identifier, @houseId, @data)
        ]]

        MySQL.Async.execute(sqlQuery, {
            ["@identifier"] = player["identifier"],
            ["@houseId"] = motelData["uniqueId"],
            ["@data"] = json.encode(motelData)
        }, function(rowsChanged)
            if rowsChanged > 0 then
                if not cachedData["houses"][motelRoom] then
                    cachedData["houses"][motelRoom] = {}
                    cachedData["houses"][motelRoom]["rooms"] = {}
                end
    
                table.insert(cachedData["houses"][motelRoom]["rooms"], {
                    ["motelData"] = motelData
                })

                TriggerClientEvent("james_motels:eventHandler", -1, "update_motels", cachedData["houses"])

                if callback then
                    callback(true, motelData["uniqueId"])
                end
            else
                if callback then
                    callback(false)
                end
            end
        end)
    end
end

GetCharacterName = function(player, callback)
    if not player then return end

    local sqlQuery = [[
        SELECT
            firstname, lastname
        FROM
            users
        WHERE
            identifier = @identifier
    ]]

    MySQL.Async.fetchAll(sqlQuery, {
        ["@identifier"] = player["identifier"]
    }, function(response)
        if not response[1] then
            cachedData["names"][player["source"]] = {
                ["firstname"] = GetPlayerName(player["source"]),
                ["lastname"] = GetPlayerName(player["source"])
            }
        else
            cachedData["names"][player["source"]] = {
                ["firstname"] = response[1]["firstname"],
                ["lastname"] = response[1]["lastname"]
            }
        end

        callback(cachedData["names"][player["source"]])
    end)
end

UpdateStorageDatabase = function(storageId, newTable)
    local sqlQuery = [[
        INSERT
            INTO
        mp_houses_storages
            (storageId, storageData)
        VALUES
            (@id, @data)
        ON DUPLICATE KEY UPDATE
            storageData = @data
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@id"] = storageId,
        ["@data"] = json.encode(newTable)
    })
end