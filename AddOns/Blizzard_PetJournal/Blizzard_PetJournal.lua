

local COMPANION_BUTTON_HEIGHT = 46;
local MOUNT_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3;
local NUM_PET_ABILITIES = 6;
PET_ACHIEVEMENT_CATEGORY = 15117;
local MAX_PET_LEVEL = 25;


StaticPopupDialogs["BATTLE_PET_RENAME"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 16,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		C_PetJournal.SetCustomName(PetJournal.menuPetID, text);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		C_PetJournal.SetCustomName(PetJournal.menuPetID, text);
		parent:Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLE_PET_PUT_IN_CAGE"] = {
	text = PET_PUT_IN_CAGE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetJournal.CagePetByID(PetJournal.menuPetID);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLE_PET_RELEASE"] = {
	text = PET_RELEASE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	maxLetters = 30,
	OnAccept = function(self)
		C_PetJournal.ReleasePetByID(PetJournal.menuPetID);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

function PetJournalParent_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	PetJournalParent_UpdateSelectedTab(self);
end

function PetJournalParent_UpdateSelectedTab(self)
	local selected = PanelTemplates_GetSelectedTab(self);
	if ( selected == 1 ) then
		MountJournal:Show();
		PetJournal:Hide();
	else
		MountJournal:Hide();
		PetJournal:Show();
	end
end

function PetJournalParent_OnShow(self)
	PetJournalParent_UpdateSelectedTab(self);
	UpdateMicroButtons();
end

function PetJournalParent_OnHide(self)
	UpdateMicroButtons();
end

function PetJournal_OnLoad(self)
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
	self:RegisterEvent("PET_JOURNAL_PET_DELETED");
	self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
	self:RegisterEvent("COMPANION_UPDATE");
	
	
	self.listScroll.update = PetJournal_UpdatePetList;
	self.listScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.listScroll, "CompanionListButtonTemplate", 44, 0);
	
	
	--PanelTemplates_DeselectTab(PetJournalTab2);
	PetJournal.isWild = false;
	UIDropDownMenu_Initialize(self.petOptionsMenu, PetOptionsMenu_Init, "MENU");
end


function PetJournal_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	PetJournal_UpdatePetList();
	PetJournal_UpdatePetLoadOut();
	
	local numPoints = 0;
	local _, numCompleted = GetCategoryNumAchievements(PET_ACHIEVEMENT_CATEGORY);
	for i=1,numCompleted do
		local _, name, points = GetAchievementInfo(PET_ACHIEVEMENT_CATEGORY, i);
		numPoints = numPoints + points;
	end
	PetJournal.AchievementStatus.SumText:SetText(numPoints);
end


function PetJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	PetJournal.SpellSelect:Hide();
end


function PetJournal_OnEvent(self, event, ...)
	if event == "PET_JOURNAL_PET_DELETED" then
		local petID = ...;
		if(PetJournal.pcPetID == petID) then
			PetJournal_HidePetCard();
		end
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
		PetJournal_UpdatePetLoadOut();
	elseif event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FindPetCardIndex();
		PetJournal_UpdatePetList();
	elseif event == "BATTLE_PET_CURSOR_CLEAR" then
		PetJournal.Loadout.Pet1.setButton:Hide();
		PetJournal.Loadout.Pet2.setButton:Hide();
		PetJournal.Loadout.Pet3.setButton:Hide();
	elseif event == "COMPANION_UPDATE" then
		local companionType = ...;
		if companionType == "CRITTER" then
			PetJournal_UpdatePetList();
			PetJournal_UpdateSummonButtonState();
		end
	end
end

function PetJournal_UpdateSummonButtonState()
	if ( PetJournal.pcPetID ) then
		PetJournal.SummonButton:Enable();
	else
		PetJournal.SummonButton:Disable();
	end

	if ( PetJournal.pcPetID and PetJournal.pcPetID == C_PetJournal.GetSummonedPetID() ) then
		PetJournal.SummonButton:SetText(PET_DISMISS);
	else
		PetJournal.SummonButton:SetText(BATTLE_PET_SUMMON);
	end
end


function PetJournal_OnTabClick(isWild)
	PetJournal.isWild = isWild;
	if isWild then
		PanelTemplates_DeselectTab(PetJournalTab1);
		PanelTemplates_SelectTab(PetJournalTab2);
	else
		PanelTemplates_DeselectTab(PetJournalTab2);
		PanelTemplates_SelectTab(PetJournalTab1);
	end
	PetJournal_UpdatePetList();
end

function PetJournalLoadout_GetRequiredLevel(loadoutPlate, abilityID)
	for i=1, NUM_PET_ABILITIES do
		if ( loadoutPlate.abilities[i] == abilityID ) then
			return loadoutPlate.abilityLevels[i];
		end
	end
	return 0;
end

function PetJournal_UpdatePetAbility(abilityFrame, abilityID, petID)
	--Get the info for the pet that has this ability
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);

	local requiredLevel = PetJournalLoadout_GetRequiredLevel(abilityFrame:GetParent(), abilityID);

	local name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(abilityID);
	abilityFrame.icon:SetTexture(icon);
	abilityFrame.abilityID = abilityID;
	abilityFrame.petID = petID;
	abilityFrame.speciesID = speciesID;
	abilityFrame.selected:Hide();


	--Display info about the required level
	local levelTooLow = requiredLevel > level;
	abilityFrame.icon:SetDesaturated(levelTooLow);
	abilityFrame.BlackCover:SetShown(levelTooLow);
	abilityFrame.LevelRequirement:SetText(requiredLevel);
	abilityFrame.LevelRequirement:SetShown(levelTooLow);
	if ( levelTooLow ) then
		abilityFrame.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		abilityFrame.additionalText = nil;
	end
end

function PetJournal_ShowPetSelect(self)
	local slotFrame = self:GetParent();
	local abilities = slotFrame.abilities;
	local slotIndex = slotFrame:GetID();

	local abilityIndex = self:GetID();
	local spellIndex1 = abilityIndex;
	local spellIndex2 = spellIndex1 + 3;

	--Get the info for the pet that has this ability
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(slotFrame.petID);
	
	if PetJournal.SpellSelect:IsShown() then 
		if PetJournal.SpellSelect.slotIndex == slotIndex and 
			PetJournal.SpellSelect.abilityIndex == abilityIndex then
			PetJournal.SpellSelect:Hide();
			self.selected:Hide();
			return;
		else
			PetJournal.Loadout["Pet"..PetJournal.SpellSelect.slotIndex]["spell"..PetJournal.SpellSelect.abilityIndex].selected:Hide();
		end
	end
	self.selected:Show();
	PetJournal.SpellSelect.slotIndex = slotIndex;
	PetJournal.SpellSelect.abilityIndex = abilityIndex;
	PetJournal_HideAbilityTooltip();
	
	--Setup spell one
	local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex1]);
	local requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex1]);
	if ( requiredLevel > level ) then
		PetJournal.SpellSelect.Spell1.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		PetJournal.SpellSelect.Spell1.additionalText = nil;
	end
	PetJournal.SpellSelect.Spell1:SetEnabled(requiredLevel <= level);
	PetJournal.SpellSelect.Spell1.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell1.BlackCover:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell1.LevelRequirement:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell1.LevelRequirement:SetText(requiredLevel);
	PetJournal.SpellSelect.Spell1.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell1.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell1.abilityID = abilities[spellIndex1];
	PetJournal.SpellSelect.Spell1.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell1.speciesID = slotFrame.speciesID;
	--Setup spell two
	name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[spellIndex2]);
	requiredLevel = PetJournalLoadout_GetRequiredLevel(slotFrame, abilities[spellIndex2]);
	if ( requiredLevel > level ) then
		PetJournal.SpellSelect.Spell2.additionalText = format(PET_ABILITY_REQUIRES_LEVEL, requiredLevel);
	else
		PetJournal.SpellSelect.Spell2.additionalText = nil;
	end
	PetJournal.SpellSelect.Spell2:SetEnabled(requiredLevel <= level);
	PetJournal.SpellSelect.Spell2.icon:SetTexture(icon);
	PetJournal.SpellSelect.Spell2.BlackCover:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell2.LevelRequirement:SetShown(requiredLevel > level);
	PetJournal.SpellSelect.Spell2.LevelRequirement:SetText(requiredLevel);
	PetJournal.SpellSelect.Spell2.slotIndex = slotIndex;
	PetJournal.SpellSelect.Spell2.abilityIndex = abilityIndex;
	PetJournal.SpellSelect.Spell2.abilityID = abilities[spellIndex2];
	PetJournal.SpellSelect.Spell2.petID = slotFrame.petID;
	PetJournal.SpellSelect.Spell2.speciesID = slotFrame.speciesID;
	
	
	PetJournal.SpellSelect.Spell1:SetChecked(self.abilityID == abilities[spellIndex1]);
	PetJournal.SpellSelect.Spell2:SetChecked(self.abilityID == abilities[spellIndex2]);
	
	PetJournal.SpellSelect:SetPoint("TOP", self, "BOTTOM", 0, 0);
	PetJournal.SpellSelect:Show();
end


function PetJournal_UpdatePetLoadOut()
	PetJournal.SpellSelect:Hide();
	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
		if (petID > 0) then
			local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
			C_PetJournal.GetPetAbilityList(speciesID, loadoutPlate.abilities, loadoutPlate.abilityLevels);	--Read ability/ability levels into the correct tables

			--Find out how many abilities are usable due to level
			local numUsableAbilities = 0;
			for j=1, #loadoutPlate.abilityLevels do
				if ( loadoutPlate.abilityLevels[j] and level >= loadoutPlate.abilityLevels[j] ) then
					numUsableAbilities = numUsableAbilities + 1;
				end
			end

			--If we don't have something in a flyout, automatically put there the lower level ability
			if ( ability1ID == 0 and loadoutPlate.abilities[1] ) then
				ability1ID = loadoutPlate.abilities[1];
				C_PetJournal.SetAbility(i, 1, ability1ID);
			end
			if ( ability2ID == 0 and loadoutPlate.abilities[2] ) then
				ability2ID = loadoutPlate.abilities[2];
				C_PetJournal.SetAbility(i, 2, ability2ID);
			end
			if ( ability3ID == 0 and loadoutPlate.abilities[3] ) then
				ability3ID = loadoutPlate.abilities[3];
				C_PetJournal.SetAbility(i, 3, ability3ID);
			end
			loadoutPlate.name:Show();
			loadoutPlate.subName:Show();
			loadoutPlate.level:Show();
			loadoutPlate.icon:Show();
			loadoutPlate.shadows:Show();
			loadoutPlate.iconBorder:Show();
			loadoutPlate.abilitiesLabel:Show();
			loadoutPlate.spell1:Show();
			loadoutPlate.spell2:Show();
			loadoutPlate.spell3:Show();

			if customName then
				loadoutPlate.name:SetText(customName);
				loadoutPlate.name:SetHeight(12);
				loadoutPlate.subName:Show();
				loadoutPlate.subName:SetText(name);
			else
				loadoutPlate.name:SetText(name);
				loadoutPlate.name:SetHeight(30);
				loadoutPlate.subName:Hide();
			end
			loadoutPlate.level:SetText(level);
			loadoutPlate.icon:SetTexture(icon);
			
			loadoutPlate.model:Show();
			if displayID ~= 0 and displayID ~= loadoutPlate.displayID then
				loadoutPlate.displayID = displayID;
				loadoutPlate.model:SetDisplayInfo(displayID);
			elseif creatureID ~= 0 and creatureID ~= loadoutPlate.creatureID then
				loadoutPlate.creatureID = creatureID;
				loadoutPlate.model:SetCreature(creatureID);
			end
				
			loadoutPlate.petTypeIcon:SetTexture(GetPetTypeTexture(petType));	
			loadoutPlate.petID = petID;
			loadoutPlate.speciesID = speciesID;
			loadoutPlate.helpFrame:Hide();
			if(level < MAX_PET_LEVEL) then
				loadoutPlate.xpBar:Show();
			else
				loadoutPlate.xpBar:Hide();
			end
				
			loadoutPlate.xpBar:SetMinMaxValues(0, maxXp);
			loadoutPlate.xpBar:SetValue(xp);
			loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
			
			PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID, petID);
			PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID, petID);

			--Only show flyouts if the person already has the first 3 abilities.
			if ( numUsableAbilities < 3 ) then
				loadoutPlate.spell1:Disable();
				loadoutPlate.spell2:Disable();
				loadoutPlate.spell3:Disable();
			else
				loadoutPlate.spell1:Enable();
				loadoutPlate.spell2:Enable();
				loadoutPlate.spell3:Enable();
			end
		else
			loadoutPlate.name:Hide();
			loadoutPlate.subName:Hide();
			loadoutPlate.level:Hide();
			loadoutPlate.icon:Hide();
			loadoutPlate.model:Hide();			
			loadoutPlate.xpBar:Hide();
			loadoutPlate.spell1:Hide();
			loadoutPlate.spell2:Hide();
			loadoutPlate.spell3:Hide();
			loadoutPlate.shadows:Hide();
			loadoutPlate.iconBorder:Hide();
			loadoutPlate.abilitiesLabel:Hide();
			if(locked) then
				loadoutPlate.helpFrame:Show();
			else
				loadoutPlate.helpFrame:Hide();
			end
		end
	end
	
	PetJournal.Loadout.Pet1.setButton:Hide();
	PetJournal.Loadout.Pet2.setButton:Hide();
	PetJournal.Loadout.Pet3.setButton:Hide();
end


function PetJournal_UpdatePetList()
	local scrollFrame = PetJournal.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local petButtons = scrollFrame.buttons;
	local pet, index;
	
	local isWild = PetJournal.isWild;
	
	local numPets, numOwned = C_PetJournal.GetNumPets(isWild);
	PetJournal.petCount:SetFormattedText(MAX_BATTLE_PET_TEXT, numOwned);
	
	local summonedPetID = C_PetJournal.GetSummonedPetID();

	for i = 1,#petButtons do
		pet = petButtons[i];
		index = offset + i;
		if index <= numPets then
			local petID, speciesID, isOwned, customName, level, favorite, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByIndex(index, isWild);
			
			if customName then
				pet.name:SetText(customName);
				pet.name:SetHeight(12);
				pet.subName:Show();
				pet.subName:SetText(name);
			else
				pet.name:SetText(name);
				pet.name:SetHeight(30);
				pet.subName:Hide();
			end
			pet.icon:SetTexture(icon);
			pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
			
			
			--TODO: Add favorite checking. Needs Gameplay
			pet.favorite:Hide();
			
			if isOwned then
				pet.levelBG:Show();
				pet.level:Show();
				pet.level:SetText(level);
				pet.icon:SetDesaturated(0);
				pet.name:SetFontObject("GameFontNormal");
				pet.petTypeIcon:SetDesaturated(0);
				pet.dragButton:Enable();
			else
				pet.levelBG:Hide();
				pet.level:Hide();
				pet.icon:SetDesaturated(1);
				pet.name:SetFontObject("GameFontDisable");
				pet.petTypeIcon:SetDesaturated(1);
				pet.dragButton:Disable();
			end

			if ( petID and petID == summonedPetID ) then
				pet.dragButton.ActiveTexture:Show();
			else
				pet.dragButton.ActiveTexture:Hide();
			end

			pet.petID = petID;
			pet.speciesID = speciesID;
			pet.index = index;
			pet.owned = isOwned;
			pet:Show();
			if pet.showingTooltip then
				GameTooltip:SetItemByID(petID);
			end
			
			--Update Petcard Button
			if PetJournal.pcIndex == index then
				pet.selected = true;
				pet.selectedTexture:Show();
			else
				pet.selected = false;
				pet.selectedTexture:Hide()
			end
		else
			pet:Hide();
		end
	end
	
	local totalHeight = numPets * COMPANION_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end


function PetJournal_OnSearchTextChanged(self)
	local text = self:GetText();
	if text == SEARCH then
		C_PetJournal.SetSearchFilter("");
		return;
	end
	
	C_PetJournal.SetSearchFilter(text);
end


function PetJournalDragButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		local parent = self:GetParent();
		if ( parent.owned ) then
			PetJournal_ShowPetDropdown(parent.index, self, 0, 0);
		end
	else
		PetJournalDragButton_OnDragStart(self);
	end
end

function PetJournalDragButton_OnDragStart(self)
	C_PetJournal.PickupPet(self:GetParent().petID, PetJournal.isWild);

	for i=1,MAX_ACTIVE_PETS do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
		if(locked) then
			PetJournal.Loadout["Pet"..i].setButton:Hide();
		else
			PetJournal.Loadout["Pet"..i].setButton:Show();
		end
	end
end

function PetJournal_ShowPetDropdown(index, anchorTo, offsetX, offsetY)
	PetJournal.menuPetIndex = index;
	PetJournal.menuPetID = C_PetJournal.GetPetInfoByIndex(index);
	ToggleDropDownMenu(1, nil, PetJournal.petOptionsMenu, anchorTo, offsetX, offsetY);
end


function PetJournal_TogglePetCardByID(petID)
	PetJournal.pcPetID = petID;
	PetJournal.pcSpeciesID = C_PetJournal.GetPetInfoByPetID(petID);
	
	PetJournal_FindPetCardIndex();
	PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
	PetJournal.PetCardList:Show();
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end


function PetJournal_TogglePetCard(index)
	if PetJournal.PetCardList:IsShown() and PetJournal.pcIndex == index then
		PetJournal_HidePetCard()
	else
		PetJournal.pcIndex = index;
		PetJournal.pcPetID, PetJournal.pcSpeciesID, owned = C_PetJournal.GetPetInfoByIndex(index, PetJournal.isWild);		
		if not owned then
			PetJournal.pcPetID = nil;
		end
		PetJournal_UpdatePetCard(PetJournal.PetCardList.MainCard);
		PetJournal.PetCardList:Show();
		PetJournal_UpdatePetList();
		PetJournal_UpdateSummonButtonState();
	end
end


function PetJournal_FindPetCardIndex()
	PetJournal.pcIndex = nil;
	local numPets = C_PetJournal.GetNumPets(PetJournal.isWild);
	for i = 1,numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(i, isWild);
		if (owned and petID == PetJournal.pcPetID) or
			(not owned and speciesID == PetJournal.pcSpeciesID)  then
			PetJournal.pcIndex = i;
			break;
		end
	end
end


function PetJournal_HidePetCard()
	PetJournal.PetCardList:Hide();
	PetJournal.pcIndex = nil;
	PetJournal.pcPetID = nil;
	PetJournal.pcSpeciesID = nil;
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end


function PetJournal_UpdatePetCard(self)
	PetJournal.SpellSelect:Hide();

	local speciesID, customName, level, name, icon, petType, creatureID, xp, maxXp, displayID, sourceText, description, _;		
	if PetJournal.pcPetID then
		speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description = C_PetJournal.GetPetInfoByPetID(PetJournal.pcPetID);
		self.level:SetText(level);
		self.level:Show();
		self.levelBG:Show();
		self.xpBar:Show();
		self.xpBar:SetMinMaxValues(0, maxXp);
		self.xpBar:SetValue(xp);
		self.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
		
		--Stats
		self.statsFrame:Show();
		local health, attack, speed, rarity = C_PetJournal.GetPetStats(PetJournal.pcPetID);
		self.statsFrame.healthValue:SetText(health);
		self.statsFrame.attackValue:SetText(attack);
		self.statsFrame.speedValue:SetText(speed);
		self.statsFrame.rarityValue:SetText(rarity);
	else
		speciesID = PetJournal.pcSpeciesID;
		name, icon, petType, creatureID, sourceText, description = C_PetJournal.GetPetInfoBySpeciesID(PetJournal.pcSpeciesID);
		self.level:Hide();
		self.levelBG:Hide();
		self.xpBar:Hide();
		self.statsFrame:Hide();
	end

	self.PetTypeFrame.Label:SetText(_G["BATTLE_PET_NAME_"..petType]);
	self.PetTypeFrame.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);
	self.PetTypeFrame.abilityID = PET_BATTLE_PET_TYPE_PASSIVES[petType];
	self.PetTypeFrame.petID = PetJournal.pcPetID;
	self.PetTypeFrame.speciesID = speciesID;
	
	if customName then
		self.name:SetText(customName);
		self.name:SetHeight(12);
		self.subName:Show();
		self.subName:SetText(name);
	else
		self.name:SetText(name);
		self.name:SetHeight(30);
		self.subName:Hide();
	end
	
	self.icon:SetTexture(icon);

	self.Location.sourceText = sourceText;
	if ( description ~= "" ) then
		self.Location.description = format([["%s"]], description);
	else
		self.Location.description = nil;
	end
	self.Location.speciesName = name;
	
	self.model:Show();
	if displayID and displayID ~= 0 and displayID ~= self.displayID then
		self.displayID = displayID;
		self.model:SetDisplayInfo(displayID);
	elseif creatureID ~= 0 and creatureID ~= self.creatureID then
		self.creatureID = creatureID;
		self.model:SetCreature(creatureID);
	end
		
	self.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
	
	--Update pet abilites
	local abilities, levels = C_PetJournal.GetPetAbilityList(speciesID);
	for i=1,NUM_PET_ABILITIES do
		local spellFrame = self["spell"..i];
		if abilities[i] then
			local name, icon, petType = C_PetJournal.GetPetAbilityInfo(abilities[i]);
			spellFrame.name:SetText(name);
			spellFrame.icon:SetTexture(icon);
			spellFrame.petTypeIcon:SetTexture(GetPetTypeTexture(petType) );
			spellFrame.abilityID = abilities[i];
			spellFrame.petID = PetJournal.pcPetID;
			spellFrame.speciesID = speciesID;
			spellFrame:Show();
		else
			spellFrame:Hide();
		end
	end
	
	Model_Reset(self.model);
end


function GetPetTypeTexture(petType) 
	if PET_TYPE_SUFFIX[petType] then
		return "Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType];
	else
		return "Interface\\PetBattles\\PetIcon-NO_TYPE";
	end
end


function PetJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PetJournalFilterDropDown_Initialize, "MENU");
end


function PetJournalFilterDropDown_Initialize(self, level)
	
	local info = UIDropDownMenu_CreateInfo();
	
	if level == 1 then
	
		info.text = COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, value);
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = NOT_COLLECTED
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, value);
						end 
		info.keepShownOnClick = true;
		info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		
		info.text = FAVORITES
		info.func = 	function(_, _, _, value)
							C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, value);
						end 
		info.keepShownOnClick = true;
		--info.checked = not C_PetJournal.IsFlagFiltered(LE_PET_JOURNAL_FLAG_FAVORITES);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		
		info.keepShownOnClick = true;
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;
				
		info.text = PET_FAMILIES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
		
		info.text = SOURCES
		info.value = 2;
		UIDropDownMenu_AddButton(info, level)
	
	else --if level == 2 then	
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;
			info.keepShownOnClick = true;
				
		
			info.text = CHECK_ALL
			info.func = function()
							C_PetJournal.AddAllPetTypesFilter();
							UIDropDownMenu_RefreshAll(PetJournalFilterDropDown);
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							C_PetJournal.ClearAllPetTypesFilter();
							UIDropDownMenu_RefreshAll(PetJournalFilterDropDown);
						end
			UIDropDownMenu_AddButton(info, level)
		
			info.notCheckable = false;
			local numTypes = C_PetJournal.GetNumPetTypes();
			for i=1,numTypes do
				info.text = _G["BATTLE_PET_NAME_"..i];
				info.func = function(_, _, _, value)
							C_PetJournal.SetPetTypeFilter(i, value);
						end
				info.checked = function() return not C_PetJournal.IsPetTypeFiltered(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
		
		end
	end
end


function PetOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	info.text = BATTLE_PET_SUMMON
	info.func = function() C_PetJournal.SummonPetByID(PetJournal.menuPetID); end
	UIDropDownMenu_AddButton(info, level)
	
	info.text = BATTLE_PET_RENAME
	info.func = 	function() StaticPopup_Show("BATTLE_PET_RENAME"); end 
	UIDropDownMenu_AddButton(info, level)
		
	info.text = BATTLE_PET_FAVORITE;--BATTLE_PET_UNFAVORITE
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
	
	info.text = BATTLE_PET_RELEASE;
	info.func = function() StaticPopup_Show("BATTLE_PET_RELEASE"); end
	UIDropDownMenu_AddButton(info, level)

	if(PetJournal.menuPetID and C_PetJournal.PetIsTradable(PetJournal.menuPetID)) then
		info.text = BATTLE_PET_PUT_IN_CAGE;
		info.func =  	function() StaticPopup_Show("BATTLE_PET_PUT_IN_CAGE"); end 
		UIDropDownMenu_AddButton(info, level)
	end
	
	info.text = CANCEL
	UIDropDownMenu_AddButton(info, level)
end

---------------------------------------
-------Ability Tooltip stuff-----------
---------------------------------------

local PET_JOURNAL_ABILITY_INFO = {};

function PET_JOURNAL_ABILITY_INFO:GetAbilityID()
	return self.abilityID;
end

function PET_JOURNAL_ABILITY_INFO:GetCooldown()
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetRemainingDuration()
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:IsInBattle()
	return false;
end

function PET_JOURNAL_ABILITY_INFO:GetHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return max health
	return 100;
end

function PET_JOURNAL_ABILITY_INFO:GetMaxHealth(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return max health
	return 100;
end

function PET_JOURNAL_ABILITY_INFO:GetAttackStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return attack stat
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetSpeedStat(target)
	self:EnsureTarget(target);
	if ( self.petID ) then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(self.petID);
	else
		--Do something with self.speciesID.
	end
	--TODO: return speed stat
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:GetState(stateID, target)
	return 0;
end

function PET_JOURNAL_ABILITY_INFO:EnsureTarget(target)
	if ( target == "default" ) then
		target = "self";
	end
	if ( target ~= "self" ) then
		GMError("Only \"self\" unit supported in journal");
	end
end


function PetJournal_ShowAbilityTooltip(self, abilityID, speciesID, petID, additionalText)
	if ( abilityID and abilityID > 0 ) then
		PET_JOURNAL_ABILITY_INFO.abilityID = abilityID;
		PET_JOURNAL_ABILITY_INFO.speciesID = speciesID;
		PET_JOURNAL_ABILITY_INFO.petID = petID;
		PetJournalPrimaryAbilityTooltip:ClearAllPoints();
		PetJournalPrimaryAbilityTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0);
		PetJournalPrimaryAbilityTooltip.anchoredTo = self;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, PET_JOURNAL_ABILITY_INFO, additionalText);
		PetJournalPrimaryAbilityTooltip:Show();
	end
end


local CompareInfo1 = {};
local CompareInfo2 = {};
setmetatable(CompareInfo1, {__index = PET_JOURNAL_ABILITY_INFO});
setmetatable(CompareInfo2, {__index = PET_JOURNAL_ABILITY_INFO});
function PetJournal_ShowAbilityCompareTooltip(abilityID1, abilityID2, speciesID, petID)
	if ( abilityID1 and abilityID2 ) then
		CompareInfo1.abilityID = abilityID1;
		CompareInfo1.speciesID = speciesID;
		CompareInfo1.petID = petID;
		
		CompareInfo2.abilityID = abilityID2;
		CompareInfo2.speciesID = speciesID;
		CompareInfo2.petID = petID;
		
		
		
		PetJournalSecondaryAbilityTooltip:ClearAllPoints();
		PetJournalSecondaryAbilityTooltip:SetPoint("TOPLEFT", PetJournal.SpellSelect, "RIGHT", -15, 0);
		PetJournalPrimaryAbilityTooltip:ClearAllPoints();
		PetJournalPrimaryAbilityTooltip:SetPoint("BOTTOM", PetJournalSecondaryAbilityTooltip, "TOP", 0, 5);
		
		PetJournalPrimaryAbilityTooltip.anchoredTo = PetJournal.SpellSelect;
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalPrimaryAbilityTooltip, CompareInfo1);
		SharedPetBattleAbilityTooltip_SetAbility(PetJournalSecondaryAbilityTooltip, CompareInfo2);
		PetJournalPrimaryAbilityTooltip:Show();
		PetJournalSecondaryAbilityTooltip:Show();
	end
end

function PetJournal_HideAbilityTooltip(self)
	if ( PetJournalPrimaryAbilityTooltip.anchoredTo == self or not self ) then
		PetJournalPrimaryAbilityTooltip:Hide();
	end
end

---------------------------------
---------Mount Journal-----------
---------------------------------
function MountJournal_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);
end

function MountJournal_OnEvent(self, event, ...)
	if ( event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" ) then
		MountJournal_UpdateMountList();
		MountJournal_UpdateMountDisplay();
	end
end

function MountJournal_OnShow(self)
	if ( not MountJournal_FindSelectedIndex() ) then
		MountJournal_Select(1);
	end
	MountJournal_UpdateMountList();
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = GetNumCompanions("MOUNT");

	for i=1, #buttons do
		local button = buttons[i];
		local index = i + offset;
		if ( index <= numMounts ) then
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
			button.name:SetText(creatureName);
			button.icon:SetTexture(icon);
			button.index = index;
			button.spellID = spellID;

			button.active = active;
			if ( active ) then
				button.DragButton.ActiveTexture:Show();
			else
				button.DragButton.ActiveTexture:Hide();
			end
			button:Show();
			
			if ( button.showingTooltip ) then
				GameTooltip:SetSpellByID(spellID);
			end

			if ( MountJournal.selectedSpellID == spellID ) then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end
		else
			button:Hide();
		end
	end
	local totalHeight = numMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());

	MountJournal.MountCount.Count:SetText(numMounts);
end

function MountJournal_UpdateMountDisplay()
	local index = MountJournal_FindSelectedIndex();

	if ( index ) then
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
		if ( MountJournal.MountDisplay.lastDisplayed ~= spellID ) then
			MountJournal.MountDisplay.Name:SetText(creatureName);
			MountJournal.MountDisplay.ModelFrame:SetCreature(creatureID);
			MountJournal.MountDisplay.lastDisplayed = spellID;
		end

		MountJournal.MountDisplay.Name:Show();
		MountJournal.MountDisplay.ModelFrame:Show();

		if ( active ) then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
		else
			MountJournal.MountButton:SetText(MOUNT);
		end
	else
		MountJournal.MountDisplay.Name:Hide();
		MountJournal.MountDisplay.ModelFrame:Hide();
	end
end

function MountJournal_FindSelectedIndex()
	local selectedSpellID = MountJournal.selectedSpellID;
	if ( selectedSpellID ) then
		for i=1, GetNumCompanions("MOUNT") do
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i);
			if ( spellID == selectedSpellID ) then
				return i;
			end
		end
	end

	return nil;
end

function MountJournal_Select(index)
	local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
	MountJournal.selectedSpellID = spellID;
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();
end

function MountJournal_GetSelectedSpellID()
	return MountJournal.selectedSpellID;
end

function MountJournalMountButton_OnClick(self)
	local index = MountJournal_FindSelectedIndex();
	if ( index ) then
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", index);
		if ( active ) then
			DismissCompanion("MOUNT");
		else
			CallCompanion("MOUNT", index);
		end
	end
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if ( button ~= "LeftButton" ) then
		if ( parent.active ) then
			DismissCompanion("MOUNT");
		else
			CallCompanion("MOUNT", parent.index);
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local id = parent.spellID;
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink);
		end
	else
		PickupCompanion("MOUNT", parent.index);
	end
end
