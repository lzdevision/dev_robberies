local Devision = {}

function Devision.loadRobberies(cb)
    exports.oxmysql:query('SELECT * FROM ??', { Config.RobberyTable }, cb)
end

function Devision.insertRobbery(data)
    exports.oxmysql:insert('INSERT INTO ?? (label, coords, heading, prop, propOffset, useTarget, cooldown, requiredItem, policeCall, anim, drops) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        Config.RobberyTable, data.label, json.encode(data.coords), data.heading,
        data.prop, json.encode(data.propOffset), data.useTarget and 1 or 0,
        data.cooldown, data.requiredItem, data.policeCall and 1 or 0,
        json.encode(data.anim), json.encode(data.drops)
    })
end

function Devision.updateRobbery(label, data)
    exports.oxmysql:update([[UPDATE ?? SET coords = ?, heading = ?, anim = ?, drops = ?, prop = ?, propOffset = ?, requiredItem = ?, policeCall = ?, useTarget = ?, cooldown = ? WHERE label = ?]], {
        Config.RobberyTable,
        json.encode(data.coords), data.heading, json.encode(data.anim), json.encode(data.drops),
        data.prop, json.encode(data.propOffset), data.requiredItem,
        data.policeCall and 1 or 0, data.useTarget and 1 or 0, data.cooldown, label
    })
end

function Devision.deleteRobbery(label)
    exports.oxmysql:execute('DELETE FROM ?? WHERE label = ?', { Config.RobberyTable, label })
end

return Devision