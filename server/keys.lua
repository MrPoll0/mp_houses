ESX.RegisterServerCallback("mp_houses:addKey", function(source, callback, keyData)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    local sqlQuery = [[
        INSERT
            INTO
        mp_houses_keys
            (uuid, owner, keyData, id)
        VALUES
            (@uuid, @owner, @data, @id)
        ON DUPLICATE KEY UPDATE
            keyData = @data
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@uuid"] = keyData["uuid"],
        ["@owner"] = player["identifier"],
        ["@data"] = json.encode(keyData),
        ["@id"] = keyData["id"]
    }, function(rowsChanged)
        if rowsChanged > 0 then
            callback(true)
        else
            callback(false)
        end
    end)
end)

ESX.RegisterServerCallback("james_motels:removeKey", function(source, callback, keyUUID)
    local player = ESX.GetPlayerFromId(source)

    if not player then return callback(false) end

    local sqlQuery = [[
        DELETE
            FROM
        mp_houses_keys
            WHERE
        uuid = @uuid
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@uuid"] = keyUUID
    }, function(rowsChanged)
        if rowsChanged > 0 then
            callback(true)
        else
            callback(false)
        end
    end)
end)

ESX.RegisterServerCallback("james_motels:transferKey", function(source, callback, keyData, receivePlayer)
    local player = ESX.GetPlayerFromId(source)
    local receivePlayer = ESX.GetPlayerFromId(receivePlayer)

    if not player then return callback(false) end

    local sqlQuery = [[
        UPDATE
            mp_houses_keys
        SET
            owner = @newOwner
        WHERE
            uuid = @uuid
    ]]

    MySQL.Async.execute(sqlQuery, {
        ["@uuid"] = keyData["uuid"],
        ["@newOwner"] = receivePlayer["identifier"]
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("james_motels:keyTransfered", receivePlayer["source"], keyData)

            callback(true)
        else
            callback(false)
        end
    end)
end)

ESX.RegisterServerCallback("mp:getPlayerCoordsK", function(source, callback, coords)
    local player = ESX.GetPlayerFromId(id)
    local coords = player.getCoords()

    if coords then 
        callback(coords, player)
    else
        callback(false)
    end
end)