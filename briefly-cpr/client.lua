local tries = 0
RegisterCommand('cpr', function()
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
			if IsPedDeadOrDying(GetPlayerPed(closest)) then
				if tries < 10 then 
					local closestID = GetPlayerServerId(closest)
                    -- Chance of Revive
					local chance = math.random(0, 100)
					loadAnimDict("mini@cpr@char_a@cpr_str")
					loadAnimDict("mini@cpr@char_a@cpr_def")

					TaskPlayAnim(PlayerPedId(), "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
					Citizen.Wait(7000)
					TaskPlayAnim(PlayerPedId(), "mini@cpr@char_a@cpr_def", "cpr_success", 8.0, 1.0, -1, 2, 0, 0, 0, 0)

					tries = tries + 1
					if chance <= 25 then
                        -- Revive Success
						TriggerServerEvent('reviveServerPlayer', closestID)
						TriggerEvent('chatMessage', '', {255, 255, 255}, 'You successfully revived ' .. GetPlayerName(closest) .. ' (' .. tries ..'/10 Used)')	
					else
                        -- Revive Fail
						TriggerEvent('chatMessage', '', {255, 255, 255}, 'You failed to revived ' .. GetPlayerName(closest) .. 'try again! (' .. tries ..'/10 Used)')
					end
				else
                    -- Out of Energy for a revive
					TriggerEvent('chatMessage', '', {255, 255, 255}, 'You ran out of energy, wait 2 minutes before doing CPR again.')
					Citizen.Wait(2 * 60000)
					tries = 0
					TriggerEvent('chatMessage', '', {255, 255, 255}, 'Your energy has reset, You are now able to do CPR 10 more times.')
				end
			else
                -- No One too revive
				TriggerEvent('chatMessage', '', {255, 255, 255}, '' .. GetPlayerName(closest) .. ' doesn\'t need CPR!')
			end
	    else
            -- Not near a player
    		TriggerEvent('chatMessage', '', {255, 255, 255}, '^You\'re not near a player!')
		end
	end
end)

RegisterNetEvent('reviveClientPlayer')
AddEventHandler('reviveClientPlayer', function()
	local plyCoords = GetEntityCoords(PlayerPedId(), true)
	ResurrectPed(PlayerPedId())
	SetEntityHealth(PlayerPedId(), 200)
	ClearPedTasksImmediately(PlayerPedId())
	SetEntityCoords(PlayerPedId(), plyCoords.x, plyCoords.y, plyCoords.z + 1.0, 0, 0, 0, 0)
end)

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
			table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if target ~= ply then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end