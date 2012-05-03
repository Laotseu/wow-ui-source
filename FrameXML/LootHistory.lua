
function LootHistoryFrame_OnLoad(self)
	self.itemFrames = {};
	self.expandedRolls = {};
	self.usedPlayerFrames = {};
	self.unusedPlayerFrames = {};

	self:RegisterEvent("LOOT_HISTORY_FULL_UPDATE");
	self:RegisterEvent("LOOT_HISTORY_ROLL_COMPLETE");
	self:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED");

	LootHistoryFrame_FullUpdate(self);
end

function LootHistoryFrame_OnEvent(self, event, ...)
	if ( event == "LOOT_HISTORY_FULL_UPDATE" ) then
		LootHistoryFrame_FullUpdate(self);
	elseif ( event == "LOOT_HISTORY_ROLL_COMPLETE" ) then
		LootHistoryFrame_FullUpdate(self);
	elseif ( event == "LOOT_HISTORY_ROLL_CHANGED" ) then
		local itemIdx, playerIdx = ...;
		LootHistoryFrame_UpdatePlayerRoll(self, itemIdx, playerIdx);
	end
end

function LootHistoryFrame_Hide(self)
	self:Hide();
end

function LootHistoryFrame_FullUpdate(self)
	LootHistoryFrame_RecycleAllPlayers(self);	--Recycle players? Sounds like soylent purplez.
	local numItems = C_LootHistory.GetNumItems();
	local previous = nil;
	for i=1, numItems do
		local frame = self.itemFrames[i];
		if ( not frame ) then
			frame = CreateFrame("BUTTON", nil, self.ScrollFrame.ScrollChild, "LootHistoryItemTemplate");
			self.itemFrames[i] = frame;
		end

		local rollID, itemLink, numPlayers, isDone, winnerIdx = C_LootHistory.GetItem(i);
		frame.rollID = rollID;
		frame.itemIdx = i;
		frame.itemLink = itemLink;
		LootHistoryFrame_UpdateItemFrame(self, frame);
		frame:Show();

		if ( previous ) then
			frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -5);
		else
			frame:SetPoint("TOPLEFT", 0, -2);
		end

		if ( self.expandedRolls[rollID] ) then
			local firstFrame, lastFrame = LootHistoryFrame_UpdatePlayerFrames(self, i);
			firstFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2);
			previous = lastFrame;
		else
			previous = frame;
		end
	end
end

function LootHistoryFrame_RecycleAllPlayers(self)
	for i=1, #self.usedPlayerFrames do
		local frame = self.usedPlayerFrames[i];
		frame.itemIdx = nil;
		frame.playerIdx = nil;
		frame:Hide();
		table.insert(self.unusedPlayerFrames, frame);
	end
	table.wipe(self.usedPlayerFrames);
end

function LootHistoryFrame_GetPlayerFrame(self)
	local frame = table.remove(self.unusedPlayerFrames);
	if ( not frame ) then
		frame = CreateFrame("FRAME", nil, self.ScrollFrame.ScrollChild, "LootHistoryPlayerTemplate");
	end
	table.insert(self.usedPlayerFrames, frame);
	return frame;
end

function LootHistoryFrame_UpdatePlayerFrames(self, itemIdx)
	local _, _, numPlayers, _, _ = C_LootHistory.GetItem(itemIdx);

	local firstFrame, lastFrame;

	for i=1, numPlayers do
		local frame = LootHistoryFrame_GetPlayerFrame(self);
		if ( lastFrame ) then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -1);
		else
			frame:ClearAllPoints();
		end
		firstFrame = firstFrame or frame;
		lastFrame = frame;

		frame.itemIdx = itemIdx;
		frame.playerIdx = i;
		LootHistoryFrame_UpdatePlayerFrame(self, frame);
		frame:Show();
	end
	return firstFrame, lastFrame;
end

function LootHistoryFrame_ToggleRollExpanded(self, rollID)
	LootHistoryFrame_SetRollExpanded(self, rollID, not self.expandedRolls[rollID]);
end

function LootHistoryFrame_SetRollExpanded(self, rollID, isExpanded)
	self.expandedRolls[rollID] = isExpanded;
	LootHistoryFrame_FullUpdate(self);
end

function LootHistoryFrame_UpdateItemFrame(self, itemFrame)
	local rollID, itemLink, numPlayers, isDone, winnerIdx = C_LootHistory.GetItem(itemFrame.itemIdx);
	local expanded = self.expandedRolls[rollID];

	if ( expanded ) then
		itemFrame.ToggleButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
		itemFrame.ToggleButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
		itemFrame.ToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled");
	else
		itemFrame.ToggleButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
		itemFrame.ToggleButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down");
		itemFrame.ToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled");
	end

	if ( not itemLink ) then	--We have to get this from the server, we'll get a FULL_UPDATE when it arrives
		itemFrame.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		itemFrame.IconBorder:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		itemFrame.ItemName:SetText(RETRIEVING_DATA);
		itemFrame.ItemName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		itemFrame.Icon:SetTexture(itemTexture);
		local colorInfo = ITEM_QUALITY_COLORS[itemRarity];
		itemFrame.IconBorder:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
		itemFrame.ItemName:SetText(itemName);
		itemFrame.ItemName:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
	end

	if ( isDone ) then
		itemFrame.ItemName:SetPoint("BOTTOMRIGHT", itemFrame.NameBorderRight, "RIGHT", -2, 0);
		if ( winnerIdx ) then
			local name, class, rollType, roll, isWinner = C_LootHistory.GetPlayerInfo(itemFrame.itemIdx, winnerIdx);
			
			if ( rollType == LOOT_ROLL_TYPE_NEED ) then
				itemFrame.WinnerRollType:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up");
			elseif ( rollType == LOOT_ROLL_TYPE_GREED ) then
				itemFrame.WinnerRollType:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up");
			elseif ( rollType == LOOT_ROLL_TYPE_DISENCHANT ) then
				itemFrame.WinnerRollType:SetTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up");
			elseif ( rollType == LOOT_ROLL_TYPE_PASS ) then
				itemFrame.WinnerRollType:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
			else
				itemFrame.WinnerRollType:SetTexture(nil); --Should never happen for a winner
			end

			itemFrame.WinnerRollType:ClearAllPoints();
			if ( roll ) then
				itemFrame.WinnerRollType:SetPoint("RIGHT", itemFrame.WinnerRoll, "LEFT", 2, -1);
			else
				itemFrame.WinnerRollType:SetPoint("BOTTOMRIGHT", itemFrame.NameBorderRight, "BOTTOMRIGHT", -2, 1);
			end
			itemFrame.WinnerRoll:SetText(roll or "");

			if ( name ) then
				itemFrame.WinnerName:SetText(name);
				local classColor = RAID_CLASS_COLORS[class];
				itemFrame.WinnerName:SetVertexColor(classColor.r, classColor.g, classColor.b);
			else
				itemFrame.WinnerName:SetText(UNKNOWNOBJECT);
				itemFrame.WinnerName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			end
			itemFrame.WinnerRoll:Show();
			itemFrame.WinnerRollType:Show();
			itemFrame.WinnerName:Show();
		else
			--Everyone passed
			itemFrame.WinnerRoll:Hide();
			itemFrame.WinnerRollType:Show();
			itemFrame.WinnerName:Hide();
			itemFrame.WinnerRollType:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
			itemFrame.WinnerRollType:ClearAllPoints();
			itemFrame.WinnerRollType:SetPoint("BOTTOMRIGHT", itemFrame.NameBorderRight, "BOTTOMRIGHT", -2, 1);
		end
	else
		itemFrame.ItemName:SetPoint("BOTTOMRIGHT", itemFrame.NameBorderRight, "BOTTOMRIGHT", -2, 2);
		itemFrame.WinnerRoll:Hide();
		itemFrame.WinnerRollType:Hide();
		itemFrame.WinnerName:Hide();
	end
end

function LootHistoryFrame_UpdatePlayerFrame(self, playerFrame)
	local name, class, rollType, roll, isWinner = C_LootHistory.GetPlayerInfo(playerFrame.itemIdx, playerFrame.playerIdx);
	if ( playerFrame.playerIdx % 2 == 1) then
		playerFrame.AlternatingBG:Show();
	else
		playerFrame.AlternatingBG:Hide();
	end

	if ( name ) then
		playerFrame.PlayerName:SetText(name);
		local classColor = RAID_CLASS_COLORS[class];
		playerFrame.PlayerName:SetVertexColor(classColor.r, classColor.g, classColor.b);
	else
		playerFrame.PlayerName:SetText(UNKNOWNOBJECT);
		playerFrame.PlayerName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end

	if ( rollType == LOOT_ROLL_TYPE_NEED ) then
		playerFrame.RollIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up");
	elseif ( rollType == LOOT_ROLL_TYPE_GREED ) then
		playerFrame.RollIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up");
	elseif ( rollType == LOOT_ROLL_TYPE_DISENCHANT ) then
		playerFrame.RollIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up");
	elseif ( rollType == LOOT_ROLL_TYPE_PASS ) then
		playerFrame.RollIcon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
	else
		playerFrame.RollIcon:SetTexture(nil); --TODO: Use unknown icon once created
	end

	if ( not rollType ) then
		playerFrame.RollText:SetText("... ");
	elseif ( not roll ) then
		playerFrame.RollText:SetText("");
		playerFrame.RollIcon:SetPoint("RIGHT", playerFrame, "RIGHT", -2, -1);
	else
		playerFrame.RollText:SetText(roll);
		playerFrame.RollIcon:SetPoint("RIGHT", playerFrame.RollText, "LEFT", 0, -1);
	end

	if ( isWinner ) then
		playerFrame.WinMark:Show();
	else
		playerFrame.WinMark:Hide();
	end
end

function LootHistoryFrame_UpdatePlayerRoll(self, itemIdx, playerIdx)
	for i=1, #self.usedPlayerFrames do
		local frame = self.usedPlayerFrames[i];
		if ( frame.itemIdx == itemIdx and frame.playerIdx == playerIdx ) then
			LootHistoryFrame_UpdatePlayerFrame(self, frame);
			break; --Should be only 1 frame per (itemIdx, playerIdx) tuple
		end
	end
end
