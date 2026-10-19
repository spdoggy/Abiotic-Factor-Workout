--[[
    Author: SpDoggy
    Date: 2026-08-19
    Mod Name: Instant Benching
]]

---------- Configurations ----------
-- Enable mod from the start
ModEnabled = true

-------------- Hotkeys -------------
-- Possible keys: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/key.md
-- See ModifierKey: https://github.com/UE4SS-RE/RE-UE4SS/blob/main/docs/lua-api/table-definitions/modifierkey.md
-- ModifierKeys can be combined. e.g.: {ModifierKey.CONTROL, ModifierKey.ALT} = CTRL + ALT + Q
-- Set to `nil` to disable hotkey.
ToggleKey = Key.F5
ToggleKeyModifiers = {ModifierKey.CONTROL}
------------------------------------
local Utils = require("utils")
------------------------------
-- Don't change code below --
------------------------------
ModName = "Abiotic-Workout"
ModVersion = "1.0.0"
DebugMode = false

Utils.log("Starting Abiotic-Workout mod initialization")


Debuffs = {
    Netted = "Debuff_Netted",
    NettedCannon = "Debuff_NettedCannon",
    Bleeding = "Debuff_Bleeding",
    SevereBleeding = "Debuff_SevereBleeding",
    ShockTrap = "Debuff_ShockTrap",
    Zapped = "Debuff_Zapped",
    ZappedPurple = "Debuff_ZappedPurple",
    Ignited = "Debuff_Ignited",
    IgnitedHoly = "Debuff_Ignited_Holy",
    Rooted = "Debuff_Rooted",
    Fear = "Debuff_Fear",
    Concussed = "Debuff_Concussed",
    Debuff_Tired_Legs = "Debuff_Tired_Legs",
    Debuff_LacticAcid_Legs = "Debuff_LacticAcid_Legs",
    Debuff_LacticAcid_Arms = "Debuff_LacticAcid_Arms",
}

Buffs = {
    HazSuit = "Buff_HazmatSuit",
    AirSeal = "Buff_AirtightSeal",
    LeadVest = "Buff_LeadVest",
    RadPills = "Buff_Radpills",
    HealShot = "Buff_SyringeHeal",
    Buff_Leyak360 = "Buff_Leyak360",
    Buff_LeyakSafetyZone = "Buff_LeyakSafetyZone",
    Buff_Workout_Legs = "Buff_Workout_Legs",
    Buff_Workout_Arms = "Buff_Workout_Arms",
    Buff_FogLantern  = "buff_foglantern",
    Buff_NeutrinoDampener = "Buff_NeutrinoDampener",
}



local function Handle_Server_ApplyBuff(Context, BuffRow, bOverrideDefaultDuration, NewDuration, Limb, LinkedActor, bSkipDialog)

    -- Utils.log(">>> Handle_Server_ApplyBuff <<<")

    local overrideDefaultDuration = bOverrideDefaultDuration:get() ---@type boolean
    local newDuration = NewDuration:get() ---@type float
    local limb = Limb:get() ---@type EBodyLimbs
    local linkedActor = LinkedActor:get() ---@type AActor
    local skipDialog = bSkipDialog:get() ---@type boolean

    buff_row = BuffRow:get()
    -- Utils.log("BuffRow: " .. buff_row:GetFullName())
    -- Utils.log("BuffRowClassName: " .. buff_row:GetClass():GetFullName())
    

    local actor = Context:get() -- AActor
    -- Utils.log("Actor: " .. actor:GetFullName())
    -- Utils.log("ActorClassName: " .. actor:GetClass():GetFullName())

    local actor_owner = actor:GetOwner()

    local world = Utils.GetWorld()
    if Utils.IsValid(world) then
        local gameState = world.GameState ---@type AGameStateBase
        

        if gameState and gameState.PlayerArray then
            for i = 1, #gameState.PlayerArray, 1 do
                local playerState = gameState.PlayerArray[i]
                if playerState:IsValid() and playerState.PawnPrivate:IsValid() and actor_owner ~= nil then
                    local playerName = playerState.PlayerNamePrivate:ToString()

                    if actor_owner:GetAddress() == playerState.PawnPrivate:GetAddress() then

                        local buffRow = BuffRow:get() ---@type FBuffDebuffRowHandle
                        local rowName = buffRow.RowName
                        local buffRowName = rowName:ToString()
                        
                        local player_controller = playerState:GetPlayerController()
                        local prog = player_controller.CharacterProgressionComponent
                        local sprint_check = prog.SprintingXPCheckInterval
                        prog.SprintingXPCheckInterval = 0.001
                        
                        --Utils.log("rowName: " )
                        --Utils.log(rowName)
                        --Utils.log(buffRowName)

                        if #buffRowName > 5 and buffRowName == Buffs.RadPills then
                            
                            NewDuration:set(500)
                            bOverrideDefaultDuration:set(true)
                            bSkipDialog:set(true)

                            -- TODO: Improve RadPill and Pentetic Acid Syringe
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.HazSuit, 500)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.AirSeal, 500)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.LeadVest, 500)
                        end

                        if buffRowName == Buffs.Buff_FogLantern then
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.HazSuit, 500)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.AirSeal, 500)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.LeadVest, 500)

                        end

                        if buffRowName == Debuffs.Debuff_LacticAcid_Legs then
                            msg = string.format("Server applied Debuff_LacticAcid_Legs to %s, removing... ", playerName)
                            Utils.log(msg)
                            NewDuration:set(0.001)
                            bOverrideDefaultDuration:set(true)
                            bSkipDialog:set(true)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.Buff_Workout_Legs, 200)
                        end

                        if buffRowName == Debuffs.Debuff_LacticAcid_Arms then
                            msg = string.format("Server applied Debuff_LacticAcid_Arms to %s, removing... ", playerName)
                            Utils.log(msg)
                            NewDuration:set(0.001)
                            bOverrideDefaultDuration:set(true)
                            bSkipDialog:set(true)
                            Utils.ApplyBuff(playerState.PawnPrivate, Buffs.Buff_Workout_Arms, 200)
                        end

                        if buffRowName == Buffs.HealShot then
                            playerState.PawnPrivate.CurrentThirst = playerState.PawnPrivate.CurrentThirst + 20
                            local hp_regen_tick = 3
                            local ticks_per_sec = 2 -- Must be equal to 1000/LoopAsyncRate used below
                            local duration = 45
                            local hp_regen_tick_cnt = 0
                            LoopAsync(500, function()
                                playerState.PawnPrivate:Server_HealRandomLimb(hp_regen_tick, {})
                                playerState.PawnPrivate:OnRep_CurrentHealth()
                                hp_regen_tick_cnt = hp_regen_tick_cnt + 1
                                if hp_regen_tick_cnt > (duration*ticks_per_sec) then
                                    return true
                                else
                                    return false
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end



ExecuteInGameThread(function()
    Utils.log("Initializing Instant Benching hooks")


    ExecuteWithDelay(2500, function()
    local okHook, errHook = pcall(RegisterHook,
        "/Script/AbioticFactor.CharacterBuffComponent:Server_ApplyBuff",
        Handle_Server_ApplyBuff
    )
        if not okHook then
            print("Hook registration failed: %s", tostring(errHook))
        else
            print("Hook registration success: Handle_Server_ApplyBuff")
        end
    end)

    Utils.log("Instant Benching Hooks initialized")
end)

if ToggleKey and ToggleKeyModifiers then
    local function SetModState(Enable)
        ExecuteInGameThread(function()
            -- test stuff here
        end)
    end
    
    RegisterKeyBind(ToggleKey, ToggleKeyModifiers, function()
        SetModState(not ModEnabled)
    end)
end

Utils.log("Mod loaded successfully")
