local VUI = select(2, ...)
local Module = VUI:GetModule("VUIKeystones")
local Persist = Module:NewSubmodule("Persist")

local challengeMapID

local function LoadPersist()
    local function IsInCompletedInstance()
        return select(10, C_Scenario.GetInfo()) == LE_SCENARIO_TYPE_CHALLENGE_MODE and C_ChallengeMode.GetCompletionInfo() ~= 0 and select(3, C_Scenario.GetInfo()) == 0 and challengeMapID
    end

    ScenarioTimer_OnUpdate_Old = ScenarioTimer_OnUpdate
    function ScenarioTimer_OnUpdate(self, elapsed)
        if self.block.timerID ~= -1 then
            self.timeSinceBase = self.timeSinceBase + elapsed;
        end
        self.updateFunc(self.block, floor(self.baseTime + self.timeSinceBase));
    end
    ScenarioTimerFrame:SetScript("OnUpdate", ScenarioTimer_OnUpdate)

    ScenarioTimer_Start_Old = ScenarioTimer_Start
    function ScenarioTimer_Start(block, updateFunc)
        if block.timerID == -1 then
            local mapID, level, timeElapsed, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
            ScenarioTimerFrame.baseTime = floor(timeElapsed/1000);
        else
            local _, elapsedTime = GetWorldElapsedTime(block.timerID);
            ScenarioTimerFrame.baseTime = elapsedTime;
            challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
        end
        ScenarioTimerFrame.timeSinceBase = 0;
        ScenarioTimerFrame.block = block;
        ScenarioTimerFrame.updateFunc = updateFunc;
        ScenarioTimerFrame:Show();
    end

    ScenarioTimer_Stop_Old = ScenarioTimer_Stop
    function ScenarioTimer_Stop(...)
        if IsInCompletedInstance() then
            local mapID, level, timeElapsed, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
            local name, _, timeLimit = C_ChallengeMode.GetMapInfo(challengeMapID)

            Scenario_ChallengeMode_ShowBlock(-1, floor(timeElapsed/1000), timeLimit)
        else
            ScenarioTimer_Stop_Old(...)
        end
    end

    SCENARIO_CONTENT_TRACKER_MODULE_StaticReanchor_Old = SCENARIO_CONTENT_TRACKER_MODULE.StaticReanchor
    function SCENARIO_CONTENT_TRACKER_MODULE:StaticReanchor()
        local inCompletedInstance = IsInCompletedInstance()
        local scenarioName, currentStage, numStages, flags, _, _, completed, xp, money = C_Scenario.GetInfo();
        local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
        if ( numStages == 0 and not inCompletedInstance ) then
            ScenarioBlocksFrame_Hide();
            return;
        end
        if ( ScenarioBlocksFrame:IsShown() ) then
            ObjectiveTracker_AddBlock(SCENARIO_TRACKER_MODULE.BlocksFrame);
        end
    end

    SCENARIO_CONTENT_TRACKER_MODULE_Update_Old = SCENARIO_CONTENT_TRACKER_MODULE.Update
    function SCENARIO_CONTENT_TRACKER_MODULE:Update()
        local inCompletedInstance = IsInCompletedInstance()
        local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType = C_Scenario.GetInfo();
        local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
        if ( numStages == 0 and not inCompletedInstance ) then
            ScenarioBlocksFrame_Hide();
            return;
        end
        local BlocksFrame = SCENARIO_TRACKER_MODULE.BlocksFrame;
        local objectiveBlock = SCENARIO_TRACKER_MODULE:GetBlock();
        local stageBlock = ScenarioStageBlock;

        -- if sliding, ignore updates unless the stage changed
        if ( BlocksFrame.slidingAction ) then
            if ( BlocksFrame.currentStage == currentStage ) then
                ObjectiveTracker_AddBlock(BlocksFrame);
                BlocksFrame:Show();
                return;
            else
                ObjectiveTracker_EndSlideBlock(BlocksFrame);
            end
        end

        BlocksFrame.maxHeight = SCENARIO_CONTENT_TRACKER_MODULE.BlocksFrame.maxHeight;
        BlocksFrame.currentBlock = nil;
        BlocksFrame.contentsHeight = 0;
        SCENARIO_TRACKER_MODULE.contentsHeight = 0;

        local stageName, stageDescription, numCriteria, _, _, _, numSpells, spellInfo, weightedProgress = C_Scenario.GetStepInfo();
        local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE);
        local inProvingGrounds = (scenarioType == LE_SCENARIO_TYPE_PROVING_GROUNDS);
        local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY);
        local scenariocompleted = currentStage > numStages;

        if ( scenariocompleted ) then
            ObjectiveTracker_AddBlock(stageBlock);
            ScenarioBlocksFrame_SetupStageBlock(scenariocompleted);
            stageBlock:Show();
        elseif ( inChallengeMode or inCompletedInstance ) then
            ObjectiveTracker_AddBlock(objectiveBlock);
            objectiveBlock:Show();
            
            if inCompletedInstance then
                local mapID, level, timeElapsed, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
                local name, _, timeLimit = C_ChallengeMode.GetMapInfo(challengeMapID)
                
                Scenario_ChallengeMode_ShowBlock(-1, floor(timeElapsed/1000), timeLimit)
            end
        end
    end

    ObjectiveTracker_Update_Old = ObjectiveTracker_Update
    function ObjectiveTracker_Update(reason, id)
        if IsInCompletedInstance() and not ( reason and (reason == "CHALLENGE_MODE_COMPLETED" or reason == "CHALLENGE_MODE_RESET") ) then
            return
        end
        
        ObjectiveTracker_Update_Old(reason, id)
    end

    ObjectiveTracker_ReorderModules_Old = ObjectiveTracker_ReorderModules
    function ObjectiveTracker_ReorderModules()
        if IsInActiveInstance() then
            local modules = ObjectiveTrackerFrame.MODULES;
            local modulesUIOrder = ObjectiveTrackerFrame.MODULES_UI_ORDER;
        else
            ObjectiveTracker_ReorderModules_Old()
        end
    end
end

function Persist:CHALLENGE_MODE_COMPLETED()
    ScenarioTimer_CheckTimers(GetWorldElapsedTimers())
    ObjectiveTracker_Update()
end

function Persist:Startup()
    if Module.db.profile.persistTracker and LoadPersist then
        LoadPersist()
        LoadPersist = nil
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    end
    challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
end

function Persist:AfterStartup()
    if Module.db.profile.persistTracker then
        ObjectiveTracker_Update()
    end
end

Module:RegisterSubmodule(Persist)