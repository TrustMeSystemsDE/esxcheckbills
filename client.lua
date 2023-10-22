ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand("checkbills", function()
    local player = GetPlayerPed(-1)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer == -1 or closestDistance > Config.DistanceToCheck then
        ESX.ShowNotification('Kein Spieler in der Nähe gefunden.')
        return
    end

    local job = ESX.GetPlayerData().job.name
    if job == Config.PoliceJobName or job == Config.SACSOJobName then
        ESX.TriggerServerCallback('checkBills:getPlayerBills', function(bills)
            if bills and #bills > 0 then
                local elements = {}

                for i=1, #bills, 1 do
                    table.insert(elements, {
                        label = ('Rechnung: %s, Betrag: %s'):format(bills[i].label, bills[i].amount),
                        value = bills[i].id
                    })
                end

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bills_menu',
                {
                title    = 'Offene Rechnungen',
                align    = 'top-left',
                elements = elements
                }, function(data, menu)
                local selectedBillId = data.current.value

     ESX.TriggerServerCallback('checkBills:payBill', function(success, msg)
             if success then
                ESX.ShowNotification('Rechnung wurde erfolgreich beglichen.')
                 menu.close()
            else
                  ESX.ShowNotification('Fehler: ' .. msg)
            end
    end, selectedBillId)

    end, function(data, menu)
        menu.close()
    end)

-- ...

                
            else
                ESX.ShowNotification('Der Spieler hat keine offenen Rechnungen.')
            end
        end, GetPlayerServerId(closestPlayer))
    else
        ESX.ShowNotification('Du hast nicht die erforderlichen Rechte, um dies zu tun.')
    end
end, false)
