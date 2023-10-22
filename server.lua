ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('checkBills:getPlayerBills', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    if xPlayer then
        local identifier = xPlayer.getIdentifier()

        MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(bills)
            cb(bills)
        end)
    else
        cb(nil)
    end
end)

ESX.RegisterServerCallback('checkBills:payBill', function(source, cb, billId)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM billing WHERE id = @id', {
        ['@id'] = billId
    }, function(bills)
        if bills and #bills > 0 then
            local bill = bills[1]
            local targetXPlayer = ESX.GetPlayerFromIdentifier(bill.identifier)
            
            if targetXPlayer then
                if targetXPlayer.getMoney() >= bill.amount then
                    targetXPlayer.removeMoney(bill.amount)
                    MySQL.Async.execute('DELETE FROM billing WHERE id = @id', {
                        ['@id'] = billId
                    })
                    cb(true)
                else
                    cb(false, 'Der Spieler hat nicht genug Geld.')
                end
            else
                cb(false, 'Spieler nicht online.')
            end
        else
            cb(false, 'Rechnung nicht gefunden.')
        end
    end)
end)