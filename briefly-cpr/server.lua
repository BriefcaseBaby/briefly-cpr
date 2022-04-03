RegisterServerEvent('reviveServerPlayer')
AddEventHandler('reviveServerPlayer', function(closestID)
	TriggerClientEvent('reviveClientPlayer', closestID)
end)