Config = {}
Config.RobberyTable = 'robberies'
Config.RequiredPermission = 'admin'
Config.Command = 'criarroubo'

Config.Dispatch = function()
    exports['ps-dispatch']:StoreRobbery()
end