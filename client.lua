function closeGUI()
	SetNuiFocus(0, 0)
    SendNUIMessage({ action = "hide" })
    SendNUIMessage({ action = "hideodholownik" })
    SendNUIMessage({ action = "cleargarage"})
    SendNUIMessage({ action = "clearodholownik"})
end


closeGUI()

RegisterNetEvent("seavibe_garage:usunaltko", function(vehicle)
	ESX.Game.DeleteVehicle(vehicle)
end)

function OtworzGaraz()
	local playerPed = PlayerPedId()
	if IsPedInAnyVehicle(playerPed) then
		local vehicle       = GetVehiclePedIsIn(playerPed)

		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)

		local name          = GetDisplayNameFromVehicleModel(vehicleProps.model)

		local plate         = vehicleProps.plate

		local health		= GetVehicleEngineHealth(vehicle)

        local vehicleData = {

			fuel = math.floor(GetVehicleFuelLevel(vehicle) or 0),

			engine = health,

			body = 100,

		}

        ESX.TriggerServerCallback('seavibe_garage:callback:checkIfVehicleIsOwned', function (owned)
			if owned ~= nil then                 
                TriggerServerEvent("seavibe_garage:updateState", plate, "1")
				TriggerServerEvent("seavibe_garage:server:updateOwnedVehicle", vehicleProps, vehicleData)
				exports['seavibe_carkeys']:removeKey(plate)
				TaskLeaveVehicle(playerPed, vehicle, 16)
				ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification("Nie jesteś właścicielem tego pojazdu")
			end
		end, plate)


    elseif not IsPedInAnyVehicle(PlayerPedId()) then
        SendNUIMessage({ action = "cleargarage" })
        ESX.TriggerServerCallback('seavibe_garage:callback:getVehiclesInGarage', function(vehicles)
            for i=1, #vehicles, 1 do
                local healthStatus = vehicles[i].vehicleData.engine
				if not healthStatus or healthStatus == nil then
					healthStatus = 0
				end
                if healthStatus <= 0 then
                    healthStatus = 0
				elseif healthStatus == nil then
					healthStatus = 0
				elseif healthStatus >= 1 then
                    healthStatus = math.ceil(healthStatus / 10)
                end
				
                SendNUIMessage({
                    action = "addcar",
                    number = tostring(i),
                    model = vehicles[i].vehicle.plate,
                    name = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                    fuel = vehicles[i].vehicleData.fuel,
                    engine = healthStatus,
                    body = vehicles[i].vehicleData.body,
                })
    
            end
			SetNuiFocus(1, 1)
            SendNUIMessage({ action = "show" })
        end)
    end
end


RegisterNUICallback("zamknij", function()
    closeGUI()
end)

RegisterNUICallback('wyciagnijfure', function(data, cb)
	local playerPed = PlayerPedId()
	ESX.TriggerServerCallback('seavibe_garage:callback:checkIfVehicleIsOwned', function(owned)
		local spawnCoords = GetEntityCoords(playerPed)
		ESX.Game.SpawnVehicle(owned.vehicleData.model, spawnCoords, GetEntityHeading(playerPed), function(vehicle)
			TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
			ESX.Game.SetVehicleProperties(vehicle, owned.vehicleData)
			local localVehPlate = GetVehicleNumberPlateText(vehicle)
			local localVehLockStatus = GetVehicleDoorLockStatus(vehicle)
			TriggerEvent("ls:getOwnedVehicle", vehicle, localVehPlate, localVehLockStatus)
			local networkid = NetworkGetNetworkIdFromEntity(vehicle)
			SetVehicleEngineHealth(vehicle, owned.engine)
            TriggerServerEvent("seavibe_garage:updateState", localVehPlate, "0")
			exports['seavibe_carkeys']:addKey(localVehPlate)
		end)
	end, data.rejestracja)
	closeGUI()
end)


RegisterNUICallback('odholujfurke', function(data, cb)
    TriggerServerEvent("seavibe_garage:odholuj", data.rejestracja)
	closeGUI()
end)

function OtworzOdholownik()
    SendNUIMessage({ action = "clearodholownik" })
    ESX.TriggerServerCallback('seavibe_garage:callback:getVehiclesInOdholownik', function(vehicles)
        for i=1, #vehicles, 1 do
            local healthStatus = vehicles[i].vehicleData.engine
			if not healthStatus or healthStatus == nil then
				healthStatus = 0
			end
			if healthStatus <= 0 then
				healthStatus = 0
			elseif healthStatus == nil then
				healthStatus = 0
			elseif healthStatus >= 1 then
				healthStatus = math.ceil(healthStatus / 10)
			end

            SendNUIMessage({
                action = "addcarodholownik",
                number = i,
                model = vehicles[i].vehicle.plate,
                name = GetDisplayNameFromVehicleModel(vehicles[i].vehicle.model),
                fuel = vehicles[i].vehicleData.fuel,
                engine = healthStatus,
                body = vehicles[i].vehicleData.body,
            })

            Citizen.Wait(500)
            SendNUIMessage({ action = "showodholownik" })
			SetNuiFocus(1, 1)
        end
    end)
end

RegisterNetEvent("seavibe_garage:client:opengarage", function()
    OtworzGaraz()
end)

RegisterNetEvent("seavibe_garage:client:openodholownik", function()
    OtworzOdholownik()
end)


Citizen.CreateThread(function()

	for i=1, #Config.Garages, 1 do

		local blip = AddBlipForCoord(Config.Garages[i].Marker.x, Config.Garages[i].Marker.y, Config.Garages[i].Marker.z)

		SetBlipSprite(blip, 357)

		SetBlipDisplay(blip, 4)

		SetBlipScale(blip, 0.6)

		SetBlipColour(blip, 38)

		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")

		AddTextComponentString("<font face='Poppins-Medium' size= '11'>Garaż</font>")

		EndTextCommandSetBlipName(blip)

		exports['seavibe_core']:SetBlip(blip, 'parking')



		exports['seavibe_core']:CreateActionKey("garage-"..i, Config.Garages[i].Marker, 5, {}, {

			eventName = "seavibe_garage:client:opengarage",

			args = {},

		}, {

			label = "Kliknik ~o~E~s~ aby otworzyć garaż",

		})	

		

    end

	for i=1, #Config.Impound, 1 do



		local blip = AddBlipForCoord(Config.Impound[i].x, Config.Impound[i].y, Config.Impound[i].z)

		SetBlipSprite (blip, 430)

		SetBlipDisplay(blip, 4)

		SetBlipScale(blip, 0.7)

		SetBlipColour(blip, 59)

		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")

		AddTextComponentString("<font face='Poppins-Medium' size= '11'>Odholownik</font>")

		EndTextCommandSetBlipName(blip)

		exports['seavibe_core']:SetBlip(blip, 'impound')	



		exports['seavibe_core']:CreateActionKey("impound-"..i, Config.Impound[i], 5, {}, {

			eventName = "seavibe_garage:client:openodholownik",

			args = {},

		}, {

			label = "Kliknik ~o~E~s~ aby otworzyć odholownik",

		})

    end

end)