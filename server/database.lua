if Config.CreateTableInDatabase then
    MySQL.ready(function()
        local sqlTasks = {}

        table.insert(sqlTasks, function(callback)        
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS `mp_houses` (
				  `userIdentifier` varchar(50) NOT NULL,
				  `houseId` bigint(20) NOT NULL,
				  `houseData` longtext NOT NULL,
				  `houseCreated` timestamp NOT NULL DEFAULT current_timestamp()
				) ENGINE=InnoDB DEFAULT CHARSET=latin1;
            ]], {
                callback(true)
            }, function(rowsChanged)
                ESX.Trace("Refreshed houses in database.")
            end)
        end)

        table.insert(sqlTasks, function(callback)     
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS `mp_houses_storages` (
				  `storageId` varchar(255) NOT NULL,
				  `storageData` longtext NOT NULL,
				  PRIMARY KEY (`storageId`)
				) ENGINE=InnoDB DEFAULT CHARSET=latin1;
            ]], {
                callback(true)
            }, function(rowsChanged)
                ESX.Trace("Refreshed storages in database.")
            end)
        end)
        
        table.insert(sqlTasks, function(callback)     
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS `mp_houses_furnishings` (
				  `houseId` bigint(20) NOT NULL,
				  `owner` varchar(50) NOT NULL,
				  `furnishingData` longtext DEFAULT NULL,
				  PRIMARY KEY (`houseId`) USING BTREE
				) ENGINE=InnoDB DEFAULT CHARSET=latin1;
            ]], {
                callback(true)
            }, function(rowsChanged)
                ESX.Trace("Refreshed furnishings in database.")
            end)
        end)

        table.insert(sqlTasks, function(callback)     
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS `mp_houses_keys` (
				  `uuid` bigint(20) NOT NULL DEFAULT 0,
				  `owner` varchar(50) NOT NULL,
				  `keyData` longtext NOT NULL,
				  `id` longtext DEFAULT NULL,
				  PRIMARY KEY (`uuid`)
				) ENGINE=InnoDB DEFAULT CHARSET=latin1;
            ]], {
                callback(true)
            }, function(rowsChanged)
                ESX.Trace("Refreshed keys in database.")
            end)
        end)

        table.insert(sqlTasks, function(callback)     
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS `mp_houses_ownedfurnishing` (
				  `owner` varchar(50) NOT NULL DEFAULT '',
				  `ownedFurnishingData` longtext DEFAULT NULL,
				  PRIMARY KEY (`owner`) USING BTREE
				) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]], {
                callback(true)
            }, function(rowsChanged)
                ESX.Trace("Refreshed owned furnishings in database.")
            end)
        end)

        Async.parallel(sqlTasks, function(responses)
            
        end)
    end)
end