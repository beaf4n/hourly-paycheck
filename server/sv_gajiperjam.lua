function GetJobSalary(job, grade)
    local result = MySQL.Sync.fetchScalar("SELECT salary_perjam FROM job_grades WHERE job_name = @job AND grade = @grade", {
        ["@job"] = job,
        ["@grade"] = grade
    })
    return result
end

function UpdatePaycheck(identifier, amount)
    MySQL.Sync.execute("UPDATE users SET paycheck = paycheck + @amount WHERE identifier = @identifier", {
        ["@amount"] = amount,
        ["@identifier"] = identifier
    })
end

function GetLastPlayedMinute(identifier)
    local result = MySQL.Sync.fetchScalar("SELECT last_played_minute FROM player_playtime WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    })
    if result then
        return tonumber(result)
    else
        return 0
    end
end

function UpdateLastPlayedMinute(identifier, minute)
    MySQL.Sync.execute("INSERT INTO player_playtime (identifier, last_played_minute) VALUES (@identifier, @minute) ON DUPLICATE KEY UPDATE last_played_minute = @minute", {
        ["@minute"] = minute,
        ["@identifier"] = identifier
    })
end

AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local currentMinute = os.date("%M")
        UpdateLastPlayedMinute(xPlayer.identifier, currentMinute)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        local xPlayers = ESX.GetPlayers()

        for _, player in ipairs(xPlayers) do
            local xPlayer = ESX.GetPlayerFromId(player)
            local job = xPlayer.job.name
            local grade = xPlayer.job.grade
            
            if job and grade then
                local salary = GetJobSalary(job, grade)
                if salary then
                    local currentMinute = os.date("%M")
                    local lastPlayedMinute = GetLastPlayedMinute(xPlayer.identifier)

                    local minuteDifference = currentMinute - lastPlayedMinute

                    if minuteDifference >= Config.paycheckInterval then
                        UpdatePaycheck(xPlayer.identifier, salary)
                        UpdateLastPlayedMinute(xPlayer.identifier, currentMinute)
                        TriggerClientEvent('mythic_notify:client:SendAlert', player, { type = 'inform', text = 'You receive your hourly paycheck $' .. salary })
                        print("Update Paycheck", xPlayer.identifier, "Sebesar", salary)
                    else
                        print("Player", xPlayer.identifier, "Has", minuteDifference, "Minutes Left Before Next Paycheck")
                    end
                end
            end
        end
    end
end)
