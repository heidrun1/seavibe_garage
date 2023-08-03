ESX.RegisterServerCallback('seavibe_garage:callback:getVehiclesInGarage', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
	'SELECT * FROM `owned_vehicles` WHERE owner = @identifier AND state = 1',
	{
		['@identifier'] = identifier
	},
	function(result2)
		local vehicles = {}
		for i=1, #result2, 1 do
			vehicles[#vehicles + 1] = {
				vehicle = json.decode(result2[i].vehicle),
				vehicleData = json.decode(result2[i].vehicleData),
			}
		end
		cb(vehicles)
	end)
end)


ESX.RegisterServerCallback('seavibe_garage:callback:getVehiclesInOdholownik', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll(
	'SELECT * FROM `owned_vehicles` WHERE owner = @identifier AND state = 0',
	{
		['@identifier'] = identifier
	},
	function(result2)
		local vehicles = {}
		for i=1, #result2, 1 do
			vehicles[#vehicles + 1] = {
				vehicle = json.decode(result2[i].vehicle),
				vehicleData = json.decode(result2[i].vehicleData),
			}
		end
		cb(vehicles)
	end)
end)


ESX.RegisterServerCallback('seavibe_garage:callback:checkIfVehicleIsOwned', function (source, cb, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer.identifier
	local found = nil
	local vehicleData = nil
	MySQL.Async.fetchAll(
	'SELECT * FROM owned_vehicles WHERE plate = @plate',
	{ 
		['@plate'] = plate
	},
	function (result2)
		local vehicles = {}
		for i=1, #result2, 1 do
			local vehicle = json.decode(result2[i].vehicle)
			local vehicleData = {}
			if result2[i].vehicleData ~= nil then
				vehicleData = json.decode(result2[i].vehicleData)
			end
			if vehicle.plate == plate then
				found = true

				cb({
					vehicleData = vehicle,
					fuel = vehicleData.fuel,
					engine = vehicleData.engine,
					body = vehicleData.body,
				})

				break
			end
		end
	end
	)
end)

local vehiclesData = {}

AddEventHandler('onClientMapStart', function()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            local vehicles = GetGamePool('CVehicle')
            for _, vehicle in ipairs(vehicles) do
                local plate = GetVehicleNumberPlateText(vehicle)
                local model = GetEntityModel(vehicle)
                vehiclesData[plate] = model
            end
        end
    end)
end)


function FindVehicleByPlate(plate)
    return vehiclesData[plate]
end


RegisterServerEvent("seavibe_garage:updateState", function(rejestracja, state)
	MySQL.Async.execute(
		'UPDATE owned_vehicles SET state = @state WHERE plate = @plate',
		{
			['@plate'] = rejestracja,
			['@state'] = state,
		}
	) 
end)

RegisterServerEvent("seavibe_garage:odholuj", function(rejestracja)
	local xPlayer = ESX.GetPlayerFromId(source)
	local Cost = Config.PriceOdholownik
	local PlayerMoney = xPlayer.getMoney()
	
	if PlayerMoney >= Cost then 
	  local vehicle = FindVehicleByPlate(rejestracja)
	  xPlayer.showNotification("Odholowałeś auto")
	  xPlayer.removeMoney(Cost)
	  TriggerEvent("seavibe_garage:updateState", rejestracja, "1")
	else
		xPlayer.showNotification("Nie posiadasz pieniędzy żeby odholować auta")
	end
end)


RegisterServerEvent('seavibe_garage:server:updateOwnedVehicle', function(vehicleProps, vehicleData)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll(
	   'SELECT * FROM owned_vehicles WHERE owner = @owner',
	   {
		   ['@owner'] = identifier
	   },
	   function(result2) 
		   local foundVehicleId = nil 
		   for i=1, #result2, 1 do 				
			   local vehicle = json.decode(result2[i].vehicle)
			   if vehicle.plate == vehicleProps.plate then
				   foundVehiclePlate = result2[i].plate
				   break
			   end
		   end
		   if foundVehiclePlate ~= nil then
			   MySQL.Async.execute(
				   'UPDATE owned_vehicles SET vehicle = @vehicle, vehicleid = NULL, vehicleData = @vehicleData, state = 1 WHERE plate = @plate',
				   {
					   ['@vehicle'] = json.encode(vehicleProps),
					   ['@plate'] = vehicleProps.plate,
					   ['@vehicleData'] = json.encode(vehicleData),
				   }
			   ) 
		   end
	   end
   )
end)


