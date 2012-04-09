CHARACTER_FACING_INCREMENT = 2;
MAX_RACES = 14;
MAX_CLASSES_PER_RACE = 11;
NUM_CHAR_CUSTOMIZATIONS = 5;
MIN_CHAR_NAME_LENGTH = 2;
CHARACTER_CREATE_ROTATION_START_X = nil;
CHARACTER_CREATE_INITIAL_FACING = nil;
NUM_PREVIEW_FRAMES = 14;
WORGEN_RACE_ID = 6;

PAID_CHARACTER_CUSTOMIZATION = 1;
PAID_RACE_CHANGE = 2;
PAID_FACTION_CHANGE = 3;
PAID_SERVICE_CHARACTER_ID = nil;
PAID_SERVICE_TYPE = nil;

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19, 0, 0, 0.2, 0.29, 0.33, 0.91},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05, 0.2, 0, 0, 0.90, 0.05, 0.07},
	["Player"] = {0.2, 0.5, 0.2, 0.05, 0.2, 0.05, 0.05, 0.2, 0.05, 1, 1, 1},
};
FRAMES_TO_BACKDROP_COLOR = { 
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
};
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
	["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
	["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
	["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},
	
	["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
	["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
	["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
	["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},

	["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},  
	["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
	["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
	["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},
	
	["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},   
	["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0}, 
	["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0}, 
	["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0}, 

	["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
	["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0}, 

	["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
	["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75}, 

	["GOBLIN_MALE"]		= {0.625, 0.750, 0.25, 0.5},
	["GOBLIN_FEMALE"]	= {0.625, 0.750, 0.75, 1.0},

	["WORGEN_MALE"]		= {0.625, 0.750, 0, 0.25},
	["WORGEN_FEMALE"]	= {0.625, 0.750, 0.5, 0.75},
	
	["PANDAREN_MALE"]	= {0.750, 0.875, 0, 0.25},
	["PANDAREN_FEMALE"]	= {0.750, 0.875, 0.5, 0.75},
};
CLASS_ICON_TCOORDS = {
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]	= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]	= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]	= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]	= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]	= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]	= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, 0.49609375, 0.5, 0.75},
	["MONK"]	= {0.49609375, 0.7421875, 0.5, 0.75},
};
SPACEMARINE_DISABLED = "Not available"

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT");

	self:SetSequence(0);
	self:SetCamera(0);

	CharacterCreate.numRaces = 0;
	CharacterCreate.selectedRace = 0;
	CharacterCreate.numClasses = 0;
	CharacterCreate.selectedClass = 0;
	CharacterCreate.selectedGender = 0;

	SetCharCustomizeFrame("CharacterCreate");

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharCreateCustomizationButton"..i].text:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"]);
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"];
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	if( IsBlizzCon() ) then
		CharCreateBackButton:Disable();
	end

	CharacterCreateFrame.state = "CLASSRACE";
end

function CharacterCreate_OnShow()
	for i = 1, NUM_PREVIEW_FRAMES do
		SetPreviewFrame("CharCreatePreviewFrame"..i.."Model", i);
		_G["CharCreatePreviewFrame"..i.."Model"]:SetLight(1, 0, 0, -0.707, -0.707, 0.7, 1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8);
	end

	for i=1, MAX_CLASSES_PER_RACE, 1 do
		local button = _G["CharCreateClassButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end
	for i=1, MAX_RACES, 1 do
		local button = _G["CharCreateRaceButton"..i];
		button:Enable();
		SetButtonDesaturated(button, false)
	end

	if ( PAID_SERVICE_TYPE ) then
		CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID );
		CharacterCreateNameEdit:SetText( PaidChange_GetName() );
	else
		--randomly selects a combination
		ResetCharCustomize();
		CharacterCreateNameEdit:SetText("");
		CharCreateRandomizeButton:Show();
	end

	CharacterCreateEnumerateRaces(GetAvailableRaces());
	SetCharacterRace(GetSelectedRace());
	
	CharacterCreateEnumerateClasses(GetAvailableClasses());
	local_,_,index = GetSelectedClass();
	SetCharacterClass(index);

	SetCharacterGender(GetSelectedSex())
	
	-- Hair customization stuff
	CharacterCreate_UpdateHairCustomization();

	SetCharacterCreateFacing(-15);
	
	-- setup customization
	CharacterChangeFixup();
	
	if( IsBlizzCon() ) then
		BLIZZCON_IS_A_GO = false;
		CharacterCreateAllianceLabel:Hide();
		CharacterCreateHordeLabel:Hide();
		CharacterCreateGender:Hide();
		CharCreateRandomizeButton:Hide();
		CharacterCreateRandomName:Hide();
		CharacterCreateGenderButtonMale:Hide();
		CharacterCreateGenderButtonFemale:Hide();
		CharacterCreateBanners:Hide();
		CharacterCreateOuterBorder1:Hide();
		CharacterCreateOuterBorder2:Hide();
		CharacterCreateOuterBorder3:Hide();
		CharacterCreateConfigurationBackground:Hide();

		CharCreateBlizzconFrame:Show();
		CharCreateBlizzconFrame2:Show();

		for i=1, MAX_RACES, 1 do
			_G["CharacterCreateRaceButton"..i]:Hide();
		end
		
		for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
			_G["CharacterCustomizationButtonFrame"..i]:Hide();
		end

--		CharacterCreateClassName:Hide();
--		CharacterCreateClassName:ClearAllPoints();
--		CharacterCreateClassName:SetPoint("BOTTOM", CharCreateBlizzconFrame, "BOTTOM", 0, 15);
--		CharacterCreateClassName:SetFontObject(GlueFontNormalGigantor);
		
		local previous = nil;
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			local button = _G["CharacterCreateClassButton"..i];
			if ( i == 2 or i == 6 or i == 9 or i == 11 ) then
				button:Hide();
			else
				button:SetSize(64,64);
				button:GetNormalTexture():SetSize(64,64);
				button:GetPushedTexture():SetSize(64,64);
				_G["CharacterCreateClassButton"..i.."BevelEdge"]:SetSize(64,64);
				_G["CharacterCreateClassButton"..i.."Shadow"]:SetSize(84,84);
				_G["CharacterCreateClassButton"..i.."DisableTexture"]:SetSize(60,60);
				button:ClearAllPoints();
				if ( i == 1 ) then
					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "BOTTOMLEFT", 70, 20);
--				elseif ( i == 5 ) then
--					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "TOP", 50, 30);
--				elseif ( i == 10 ) then
--					button:SetPoint("BOTTOM", CharCreateBlizzconFrame, "TOP", 0, 290);
				else
					button:SetPoint("BOTTOM", previous, "TOP", 0, 20)
				end
				previous = button;
			end
		end
	end
end

function CharacterCreate_OnHide()
	PAID_SERVICE_CHARACTER_ID = nil;
	PAID_SERVICE_TYPE = nil;
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		CharacterCreate_Back();
	end
end

function CharacterCreate_OnEvent(event, arg1, arg2, arg3)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		if ( arg1 == 0 ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(GenerateRandomName());
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(arg2);
		end
		CharacterCreateRandomName:Enable();
		CharCreateOkayButton:Enable();
		PlaySound("gsCharacterCreationLook");
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing();
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate()
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition();
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateEnumerateRaces(...)
	CharacterCreate.numRaces = select("#", ...)/3;
	if ( CharacterCreate.numRaces > MAX_RACES ) then
		message("Too many races!  Update MAX_RACES");
		return;
	end
	local coords;
	local index = 1;
	local button;
	local gender;
	local selectedSex = GetSelectedSex();
	if ( selectedSex == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	for i=1, select("#", ...), 3 do
		local name = select(i, ...);
		coords = RACE_ICON_TCOORDS[strupper(select(i+1, ...).."_"..gender)];
		_G["CharCreateRaceButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateRaceButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateRaceButton"..index];
		if ( not button  ) then
			return;
		end
		if( not IsBlizzCon() ) then
			button:Show();
		end
		button.nameFrame.text:SetText(name);
		if ( select(i+2, ...) == 1 ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.name = name;
			button.tooltip = name;
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.name = name;
			button.tooltip = name.."|n".._G[strupper(select(i+1, ...).."_".."DISABLED")];
		end
		index = index + 1;
	end
	for i=CharacterCreate.numRaces + 1, MAX_RACES, 1 do
		_G["CharCreateRaceButton"..i]:Hide();
	end
end

function CharacterCreateEnumerateClasses(...)
	CharacterCreate.numClasses = select("#", ...)/3;
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE");
		return;
	end
	local coords;
	local index = 1;
	local button;
	for i=1, select("#", ...), 3 do
		coords = CLASS_ICON_TCOORDS[strupper(select(i+1, ...))];
		_G["CharCreateClassButton"..index.."NormalTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		_G["CharCreateClassButton"..index.."PushedTexture"]:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
		button = _G["CharCreateClassButton"..index];
		button:Show();
		button.nameFrame.text:SetText(select(i, ...));
		if ( (select(i+2, ...) == 1) and (IsRaceClassValid(CharacterCreate.selectedRace, index)) ) then
			button:Enable();
			SetButtonDesaturated(button);
			button.tooltip = nil;
			_G["CharCreateClassButton"..index.."DisableTexture"]:Hide();
		else
			button:Disable();
			SetButtonDesaturated(button, 1);
			button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")];
			_G["CharCreateClassButton"..index.."DisableTexture"]:Show();
		end
		if( IsBlizzCon() ) then
			button.text:SetText(select(i, ...));
			button.text:Show();
		end
		index = index + 1;
	end
	for i=CharacterCreate.numClasses + 1, MAX_CLASSES_PER_RACE, 1 do
		_G["CharCreateClassButton"..i]:Hide();
	end
end

function SetCharacterRace(id)
	if( IsBlizzCon() ) then
		id = 7;
	end

	CharacterCreate.selectedRace = id;
	for i=1, CharacterCreate.numRaces, 1 do
		local button = _G["CharCreateRaceButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end

	-- Set background
	local backgroundFilename = GetCreateBackgroundModel();
	SetBackgroundModel(CharacterCreate, backgroundFilename);

	-- Set backdrop colors based on faction
	local name, faction = GetFactionForRace(CharacterCreate.selectedRace);
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE[faction];
	CharCreateRaceFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateClassFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreatePreviewFrame.factionBg:SetGradient("VERTICAL", 0, 0, 0, backdropColor[7], backdropColor[8], backdropColor[9]);
	CharCreateCustomizationFrameBanner:SetVertexColor(backdropColor[10], backdropColor[11], backdropColor[12]);
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	CharCreateRaceInfoFrame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	CharCreateClassInfoFrame:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	
	-- race info
	local frame = CharCreateRaceInfoFrame;
	local race, fileString = GetNameForRace();
	frame.title:SetText(race);
	fileString = strupper(fileString);
	local gender;
	if ( GetSelectedSex() == SEX_MALE ) then
		gender = "MALE";
	else
		gender = "FEMALE";
	end
	local raceText = _G["RACE_INFO_"..fileString];
	local abilityIndex = 1;
	local tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["ABILITY_INFO_"..fileString..abilityIndex];
	end
	CharCreateRaceInfoFrameScrollFrameScrollBar:SetValue(0);
	CharCreateRaceInfoFrame.scrollFrame.scrollChild.infoText:SetText(GetFlavorText("RACE_INFO_"..strupper(fileString), GetSelectedSex()).."|n|n");
	if ( abilityText and abilityText ~= "" ) then
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	else
		CharCreateRaceInfoFrame.scrollFrame.scrollChild.bulletText:SetText("");
	end	

	-- Altered form
	if (HasAlteredForm()) then
		SetPortraitTexture(CharacterCreateAlternateFormTopPortrait, 22, GetSelectedSex());
		SetPortraitTexture(CharacterCreateAlternateFormBottomPortrait, 23, GetSelectedSex());
		CharacterCreateAlternateFormTop:Show();
		CharacterCreateAlternateFormBottom:Show();
		if( IsViewingAlteredForm() ) then
			CharacterCreateAlternateFormTop:SetChecked(false);
			CharacterCreateAlternateFormBottom:SetChecked(true);
		else
			CharacterCreateAlternateFormTop:SetChecked(true);
			CharacterCreateAlternateFormBottom:SetChecked(false);
		end
	else
		CharacterCreateAlternateFormTop:Hide();
		CharacterCreateAlternateFormBottom:Hide();
	end
end

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id;
	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharCreateClassButton"..i];
		if ( i == id ) then
			button:SetChecked(1);
			if( IsBlizzCon() ) then
				button.selection:Show();
			end
		else
			button:SetChecked(0);
			button.selection:Hide();
		end
	end
	
	-- class info
	local frame = CharCreateClassInfoFrame;
	local className, classFileName, _, tank, healer, damage = GetSelectedClass();
	local abilityIndex = 0;
	local tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	abilityText = "";
	while ( tempText ) do
		abilityText = abilityText..tempText.."\n\n";
		abilityIndex = abilityIndex + 1;
		tempText = _G["CLASS_INFO_"..classFileName..abilityIndex];
	end
	CharCreateClassInfoFrame.title:SetText(className);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.bulletText:SetText(abilityText);
	CharCreateClassInfoFrame.scrollFrame.scrollChild.infoText:SetText(GetFlavorText("CLASS_"..strupper(classFileName), GetSelectedSex()).."|n|n");
	CharCreateClassInfoFrameScrollFrameScrollBar:SetValue(0);
end

function CharacterCreate_OnChar()
end

function CharacterCreate_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back();
	elseif ( key == "ENTER" ) then
		CharacterCreate_Forward();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function CharacterCreate_UpdateModel(self)
	UpdateCustomizationScene();
	self:AdvanceTime();
end

function CharacterCreate_Finish()
	PlaySound("gsCharacterCreationCreateChar");
	if( IsBlizzCon() ) then
		CreateCharacter(CharacterCreateNameEdit:GetText());
		BLIZZCON_IS_A_GO = true;
		return;
	end

	-- If something disabled this button, ignore this message.
	-- This can happen if you press enter while it's disabled, for example.
	if ( not CharCreateOkayButton:IsEnabled() ) then
		return;
	end

	if ( PAID_SERVICE_TYPE ) then
		GlueDialog_Show("CONFIRM_PAID_SERVICE");
	else
		CreateCharacter(CharacterCreateNameEdit:GetText());
	end
end

function CharacterCreate_Back()
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		PlaySound("gsCharacterCreationCancel");
		CharacterCreateFrame.state = "CLASSRACE"
		CharCreateClassFrame:Show();
		CharCreateRaceFrame:Show();
		CharCreateMoreInfoButton:Show();
		CharCreateCustomizationFrame:Hide();
		CharCreatePreviewFrame:Hide();
		CharCreateOkayButton:SetText(NEXT);
		CharacterCreateNameEdit:Hide();
		CharacterCreateRandomName:Hide();

		--back to awesome gear
		SetSelectedPreviewGearType(1);

		return;
	end

	if( IsBlizzCon() ) then
		return;
	end

	PlaySound("gsCharacterCreationCancel");
	CHARACTER_SELECT_BACK_FROM_CREATE = true;
	SetGlueScreen("charselect");
end

function CharacterCreate_Forward()
	if ( CharacterCreateFrame.state == "CLASSRACE" ) then
		CharacterCreateFrame.state = "CUSTOMIZATION"
		PlaySound("gsCharacterSelectionCreateNew");
		-- need to reload models if gender or race was changed, or class was swapped to or from DK
		local race = GetSelectedRace();
		local gender = GetSelectedSex();
		local _, class = GetSelectedClass();
		local classSwap = ( class == "DEATHKNIGHT" or CharacterCreateFrame.lastClass == "DEATHKNIGHT" ) and ( class ~= CharacterCreateFrame.lastClass );
		if ( CharacterCreateFrame.lastRace ~= race or CharacterCreateFrame.lastGender ~= gender or classSwap ) then
			CharacterCreateFrame.lastRace = race;
			CharacterCreateFrame.lastGender = gender;
			CharacterCreateFrame.lastClass = class;
			CharCreate_SetPreviewModels();
		end

		CharCreateClassFrame:Hide();
		CharCreateRaceFrame:Hide();
		CharCreateMoreInfoButton:Hide();
		CharCreateCustomizationFrame:Show();
		CharCreatePreviewFrame:Show();
		-- reselect the same customization, or select the 1st one, to apply styles
		CharCreateSelectCustomizationType(CharacterCreateFrame.customizationType or 1);
		CharCreateOkayButton:SetText(FINISH);
		CharacterCreateNameEdit:Show();
		if ( ALLOW_RANDOM_NAME_BUTTON ) then
			CharacterCreateRandomName:Show();
		end

		--You just went to customization mode - show the boring start gear
		SetSelectedPreviewGearType(0);
	else
		CharacterCreate_Finish();
	end
end

function CharacterClass_OnClick(self, id)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		local _,_,currClass = GetSelectedClass();
		if ( currClass ~= id ) then
			SetSelectedClass(id);
			SetCharacterClass(id);
			SetCharacterRace(GetSelectedRace());
			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function CharacterRace_OnClick(self, id)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass");
		if ( GetSelectedRace() ~= id ) then
			SetSelectedRace(id);
			SetCharacterRace(id);
			SetCharacterGender(GetSelectedSex());
			SetCharacterCreateFacing(-15);
			CharacterCreateEnumerateClasses(GetAvailableClasses());
			local _,_,classIndex = GetSelectedClass();
			if ( PAID_SERVICE_TYPE ) then
				classIndex = PaidChange_GetCurrentClassIndex();
			end
			SetCharacterClass(classIndex);
			
			-- Hair customization stuff
			CharacterCreate_UpdateHairCustomization();
				
			CharacterChangeFixup();
		else
			self:SetChecked(1);
		end
	else
		self:SetChecked(0);
	end
end

function SetCharacterGender(sex)
	if( IsBlizzCon() ) then
		sex = 2;
	end
	local gender;
	SetSelectedSex(sex);
	if ( sex == SEX_MALE ) then
		CharCreateMaleButton:SetChecked(1);
		CharCreateFemaleButton:SetChecked(0);
	else
		CharCreateMaleButton:SetChecked(0);
		CharCreateFemaleButton:SetChecked(1);
	end

	-- Update race images to reflect gender
	CharacterCreateEnumerateRaces(GetAvailableRaces());
	CharacterCreateEnumerateClasses(GetAvailableClasses());
 	SetCharacterRace(GetSelectedRace());
	
	local _,_,classIndex = GetSelectedClass();
	if ( PAID_SERVICE_TYPE ) then
		classIndex = PaidChange_GetCurrentClassIndex();
	end
	SetCharacterClass(classIndex);

	CharacterCreate_UpdateHairCustomization();
	CharacterChangeFixup();
end

function CharacterCustomization_Left(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, -1);
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook");
	CycleCharCustomization(id, 1);
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable();
	CharacterCreateNameEdit:SetText("...");
	RequestRandomName();
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook");
	RandomizeCharCustomization();
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT);
		CharCreate_RotatePreviews();
	end
end

function CharacterCreate_UpdateHairCustomization()
	CharCreateCustomizationButton3.text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"]);
	CharCreateCustomizationButton4.text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"]);
	CharCreateCustomizationButton5.text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return;
	end
	local icon = button:GetNormalTexture();
	if ( not icon ) then
		return;
	end
	
	icon:SetDesaturated(desaturated);
end

function GetFlavorText(tagname, sex)
	local primary, secondary;
	if ( sex == SEX_MALE ) then
		primary = "";
		secondary = "_FEMALE";
	else
		primary = "_FEMALE";
		secondary = "";
	end
	local text = _G[tagname..primary];
	if ( (text == nil) or (text == "") ) then
		text = _G[tagname..secondary];
	end
	return text;
end

function CharacterCreate_DeathKnightSwap(self)
	local _, classFilename = GetSelectedClass();
	if ( classFilename == "DEATHKNIGHT" ) then
		if (self.currentModel ~= "DEATHKNIGHT") then
			self.currentModel = "DEATHKNIGHT";
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
		end
	else
		if (self.currentModel == "DEATHKNIGHT") then
			self.currentModel = nil;
			self:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			self:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			self:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function CharacterChangeFixup()
	if ( PAID_SERVICE_TYPE ) then
		-- no class changing as a paid service
		CharCreateClassFrame:SetAlpha(0.5);
		for i=1, MAX_CLASSES_PER_RACE, 1 do
			if (CharacterCreate.selectedClass ~= i) then
				local button = _G["CharCreateClassButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			end
		end

		local numAllowedRaces = 0;
		for i=1, MAX_RACES, 1 do
			local allow = false;
			if ( PAID_SERVICE_TYPE == PAID_FACTION_CHANGE ) then
				local faction = GetFactionForRace(PaidChange_GetCurrentRaceIndex());
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) ~= faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true;
				end
			elseif ( PAID_SERVICE_TYPE == PAID_RACE_CHANGE ) then
				local faction = GetFactionForRace(PaidChange_GetCurrentRaceIndex());
				if ( (i == PaidChange_GetCurrentRaceIndex()) or ((GetFactionForRace(i) == faction) and (IsRaceClassValid(i,CharacterCreate.selectedClass))) ) then
					allow = true
				end
			elseif ( PAID_SERVICE_TYPE == PAID_CHARACTER_CUSTOMIZATION ) then
				if ( i == CharacterCreate.selectedRace ) then
					allow = true
				end
			end
			if (not allow) then
				local button = _G["CharCreateRaceButton"..i];
				button:Disable();
				SetButtonDesaturated(button, true);
			else
				numAllowedRaces = numAllowedRaces + 1;
			end
		end
		if ( numAllowedRaces > 1 ) then
			CharCreateRaceButtonsFrame:SetAlpha(1);
		else
			CharCreateRaceButtonsFrame:SetAlpha(0.5);
		end
	else
		CharCreateRaceButtonsFrame:SetAlpha(1);
		CharCreateClassFrame:SetAlpha(1);
	end
end

function CharCreateSelectCustomizationType(newType)
	ResetPreviewFramesModel();
	SetPreviewFramesFeature(newType);
	if ( newType == 1 ) then
		CharCreatePreviewLabel:SetText(CHAR_CUSTOMIZATION1_DESC);
	elseif ( newType == 2 ) then
		CharCreatePreviewLabel:SetText(CHAR_CUSTOMIZATION2_DESC);
	elseif ( newType == 3 ) then
		CharCreatePreviewLabel:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"]);
	elseif ( newType == 4 ) then
		CharCreatePreviewLabel:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"]);
	elseif ( newType == 5 ) then
		CharCreatePreviewLabel:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()]);
	end
	-- deselect previous type selection
	if ( CharacterCreateFrame.customizationType and CharacterCreateFrame.customizationType ~= newType ) then
		_G["CharCreateCustomizationButton"..CharacterCreateFrame.customizationType]:SetChecked(0);
	end
	_G["CharCreateCustomizationButton"..newType]:SetChecked(1);
	CharacterCreateFrame.customizationType = newType;
	CharCreatePreviews_Display();
end

function CharCreateSelectFeatureVariation(button)
	local previewFrame = button:GetParent();
	local style = previewFrame:GetID();
	-- uncheck previous selection
	local lastStyle = GetSelectedFeatureVariation(CharacterCreateFrame.customizationType);
	if ( lastStyle > 0 and lastStyle <= NUM_PREVIEW_FRAMES ) then
		_G["CharCreatePreviewFrame"..lastStyle].button:SetChecked(0);
	end
	previewFrame.button:SetChecked(1);
	SelectFeatureVariation(CharacterCreateFrame.customizationType, style);
end

function CharCreatePreviews_Display()
	local numStyles = GetNumFeatureVariations(CharacterCreateFrame.customizationType);
	local activeStyle = GetSelectedFeatureVariation(CharacterCreateFrame.customizationType);
	for previewIndex = 1, NUM_PREVIEW_FRAMES do
		local previewFrame = _G["CharCreatePreviewFrame"..previewIndex];
		if ( previewIndex <= numStyles ) then
			previewFrame:Show();
			if ( previewIndex == activeStyle ) then
				previewFrame.button:SetChecked(1);
			else
				previewFrame.button:SetChecked(0);
			end
		else
			previewFrame:Hide();
		end
	end
	ShowPreviewFramesVariations(CharacterCreateFrame.customizationType, offset);
end

function CharCreate_SetPreviewModels()
	SetPreviewFramesModel();
	local cameraID = 0;
	-- HACK: Worgen fix for portrait camera position
	local race = GetSelectedRace();
	local gender = GetSelectedSex();
	if ( race == WORGEN_RACE_ID and gender == SEX_MALE and not IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	for i = 1, NUM_PREVIEW_FRAMES do
		local previewFrame = _G["CharCreatePreviewFrame"..i];
		previewFrame.model:SetCustomCamera(cameraID);
	end
	CharCreate_RotatePreviews();
	ModelAdjustmentFrame_SetUp();
end

function CharCreate_RotatePreviews()
	local facing = ((GetCharacterCreateFacing())/ -180) * math.pi;
	for i = 1, NUM_PREVIEW_FRAMES do
		local model = _G["CharCreatePreviewFrame"..i].model;
		if ( model:HasCustomCamera() ) then
			model:SetCameraFacing(facing);
		end
	end
end

-- test stuff

function ModelAdjustmentFrame_SetUp()
	local model = CharCreatePreviewFrame1.model;
	if ( model:HasCustomCamera() ) then
		ModelAdjustmentFrame.setUp = nil;
		local x, y, z = model:GetCameraTarget();
		-- x
		x = floor(x * 1000 + 0.5);
		ModelAdjustmentFrameTargetXText:SetText("Target X: "..x);
		ModelAdjustmentFrameTargetX:SetMinMaxValues(x - 500, x + 500);
		ModelAdjustmentFrameTargetX:SetValue(x);
		-- y
		y = floor(y * 1000 + 0.5);
		ModelAdjustmentFrameTargetYText:SetText("Target Y: "..y);
		ModelAdjustmentFrameTargetY:SetMinMaxValues(y - 500, y + 500);
		ModelAdjustmentFrameTargetY:SetValue(y);		
		-- z
		local nz = floor(z * 1000 + 0.5);
		ModelAdjustmentFrameTargetZText:SetText("Target Z: "..nz);
		ModelAdjustmentFrameTargetZ:SetMinMaxValues(nz - 500, nz + 500);
		ModelAdjustmentFrameTargetZ:SetValue(nz);		
		-- camera z
		local cx, cy, cz = model:GetCameraPosition();
		cz = floor(cz * 1000 + 0.5);
		ModelAdjustmentFrameCameraZText:SetText("Camera Z: "..cz);
		ModelAdjustmentFrameCameraZ:SetMinMaxValues(cz - 500, cz + 500);
		ModelAdjustmentFrameCameraZ:SetValue(cz);
		-- distance
		ModelAdjustmentFrame_UpdateDistance(model);
		
		ModelAdjustmentFrame.setUp = true;		
	end
end

function ModelAdjustmentFrame_ChangeTargetX(self, value)
	if ( ModelAdjustmentFrame.setUp ) then
		local model = CharCreatePreviewFrame1.model;
		local x, y, z = model:GetCameraTarget();
		value = floor(value + 0.5);
		ModelAdjustmentFrameTargetXText:SetText("Target X: "..value);
		value = value / 1000;

		for i = 1, NUM_PREVIEW_FRAMES do
			local model = _G["CharCreatePreviewFrame"..i].model;
			model:SetCameraTarget(value, y, z);
		end		
		ModelAdjustmentFrame_UpdateDistance(model);
	end
end

function ModelAdjustmentFrame_ChangeTargetY(self, value)
	if ( ModelAdjustmentFrame.setUp ) then
		local model = CharCreatePreviewFrame1.model;
		local x, y, z = model:GetCameraTarget();
		value = floor(value + 0.5);
		ModelAdjustmentFrameTargetYText:SetText("Target Y: "..value);
		value = value / 1000;
		
		for i = 1, NUM_PREVIEW_FRAMES do
			local model = _G["CharCreatePreviewFrame"..i].model;
			model:SetCameraTarget(x, value, z);
		end		
		ModelAdjustmentFrame_UpdateDistance(model);
	end
end

function ModelAdjustmentFrame_ChangeTargetZ(self, value)
	if ( ModelAdjustmentFrame.setUp ) then
		local model = CharCreatePreviewFrame1.model;
		local x, y, z = model:GetCameraTarget();
		value = floor(value + 0.5);
		ModelAdjustmentFrameTargetZText:SetText("Target Z: "..value);
		value = value / 1000;
		
		for i = 1, NUM_PREVIEW_FRAMES do
			local model = _G["CharCreatePreviewFrame"..i].model;
			model:SetCameraTarget(x, y, value);
		end		
	end
end

function ModelAdjustmentFrame_ChangeCameraZ(self, value)
	if ( ModelAdjustmentFrame.setUp ) then
		local model = CharCreatePreviewFrame1.model;
		value = floor(value + 0.5);
		ModelAdjustmentFrameCameraZText:SetText("Camera Z: "..value);		
		value = value / 1000;
		local cx, cy, cz = model:GetCameraPosition();
		
		for i = 1, NUM_PREVIEW_FRAMES do
			local model = _G["CharCreatePreviewFrame"..i].model;
			model:SetCameraPosition(cx, cy, value);
		end			
	end
end

function ModelAdjustmentFrame_ChangeDistance(self, value)
	if ( ModelAdjustmentFrame.setUp ) then
		local model = CharCreatePreviewFrame1.model;
		value = floor(value + 0.5);
		ModelAdjustmentFrameDistanceText:SetText("Distance: "..value);
		value = value / 1000;
		
		for i = 1, NUM_PREVIEW_FRAMES do
			local model = _G["CharCreatePreviewFrame"..i].model;
			model:SetCameraDistance(value);
		end			
		
	end
end

function ModelAdjustmentFrame_UpdateDistance(model)
	local distance = model:GetCameraDistance();
	distance = floor(distance * 1000 + 0.5);
	ModelAdjustmentFrameDistanceText:SetText("Distance: "..distance);
	ModelAdjustmentFrameDistance:SetMinMaxValues(300, 2300);
	ModelAdjustmentFrameDistance:SetValue(distance);
end

function ModelAdjustmentFrame_CopyToClipboard()
	local model = CharCreatePreviewFrame1.model;
	local x, y, z = model:GetCameraTarget();
	local cx, cy, cz = model:GetCameraPosition();
	local cd = model:GetCameraDistance();
	
	local race = GetNameForRace();
	local gender = GetSelectedSex();
	local formatString = "[%s][%d] = { tx = %5.3f, ty = %5.3f, tz = %5.3f, cz = %5.3f, distance = %5.3f }"	
	CopyToClipboard(string.format(formatString, race, gender, x, y, z, cz, cd));
end

function ModelAdjustmentFrame_Reset()
	local cameraID = 0;
	-- HACK: Worgen fix for portrait camera position
	local race = GetSelectedRace();
	local gender = GetSelectedSex();
	if ( race == WORGEN_RACE_ID and gender == SEX_MALE and not IsViewingAlteredForm() ) then
		cameraID = 1;
	end

	for i = 1, NUM_PREVIEW_FRAMES do
		local previewFrame = _G["CharCreatePreviewFrame"..i];
		previewFrame.model:SetCustomCamera(cameraID);
	end
	CharCreate_RotatePreviews();
	ModelAdjustmentFrame_SetUp();
end