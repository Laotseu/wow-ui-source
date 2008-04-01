FRIENDS_TO_DISPLAY = 10;
FRIENDS_FRAME_FRIEND_HEIGHT = 34;
IGNORES_TO_DISPLAY = 20;
FRIENDS_FRAME_IGNORE_HEIGHT = 16;
WHOS_TO_DISPLAY = 17;
FRIENDS_FRAME_WHO_HEIGHT = 16;
GUILDMEMBERS_TO_DISPLAY = 13;
FRIENDS_FRAME_GUILD_HEIGHT = 14;
MAX_IGNORE = 50;
MAX_WHOS_FROM_SERVER = 50;
MAX_GUILDCONTROL_OPTIONS = 12;
CURRENT_GUILD_MOTD = "";
SHOW_OFFLINE_GUILD_MEMBERS = 1;	-- This variable is saved
GUILD_DETAIL_NORM_HEIGHT = 195
GUILD_DETAIL_OFFICER_HEIGHT = 255
MAX_GUILDBANK_TABS = 6;
MAX_GOLD_WITHDRAW = 1000;
GUILDEVENT_TRANSACTION_HEIGHT = 13;
MAX_EVENTS_SHOWN = 25;
PENDING_GUILDBANK_PERMISSIONS = {};

WHOFRAME_DROPDOWN_LIST = {
	{name = ZONE, sortType = "zone"},
	{name = GUILD, sortType = "guild"},
	{name = RACE, sortType = "race"}
};

FRIENDSFRAME_SUBFRAMES = { "FriendsListFrame", "IgnoreListFrame", "MutedListFrame", "WhoFrame", "GuildFrame", "ChannelFrame", "RaidFrame" };
function FriendsFrame_ShowSubFrame(frameName)
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();
		end	
	end 
end

function FriendsFrame_ShowDropdown(name, connected, lineID)
	HideDropDownMenu(1);
	if ( connected ) then
		FriendsDropDown.initialize = FriendsFrameDropDown_Initialize;
		FriendsDropDown.displayMode = "MENU";
		FriendsDropDown.name = name;
		FriendsDropDown.lineID = lineID;
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function FriendsFrameDropDown_Initialize()
	UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "FRIEND", nil, FriendsDropDown.name);
end

function FriendsFrame_OnLoad()
	PanelTemplates_SetNumTabs(this, 5);
	FriendsFrame.selectedTab = 1;
	PanelTemplates_UpdateTabs(this);
	this:RegisterEvent("FRIENDLIST_SHOW");
	this:RegisterEvent("FRIENDLIST_UPDATE");
	this:RegisterEvent("IGNORELIST_UPDATE");
	this:RegisterEvent("MUTELIST_UPDATE");
	this:RegisterEvent("WHO_LIST_UPDATE");
	this:RegisterEvent("GUILD_ROSTER_UPDATE");
	this:RegisterEvent("PLAYER_GUILD_UPDATE");
	this:RegisterEvent("GUILD_MOTD");
	this:RegisterEvent("VOICE_CHAT_ENABLED_UPDATE");
	FriendsFrame.playersInBotRank = 0;
	FriendsFrame.playerStatusFrame = 1;
	FriendsFrame.selectedFriend = 1;
	FriendsFrame.selectedIgnore = 1;
	FriendsFrame.guildStatus = 0;
	FriendsFrame.showFriendsList = 1;
	GuildFrame.notesToggle = 1;
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	CURRENT_GUILD_MOTD = GetGuildRosterMOTD();
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
end

function FriendsFrame_OnShow()
	VoiceChat_Toggle();
	FriendsFrame.showMutedList = nil;
	FriendsFrame_Update();
	UpdateMicroButtons();
	PlaySound("igCharacterInfoTab");
	GuildFrame.selectedGuildMember = 0;
	SetGuildRosterSelection(0);
	InGuildCheck();
end

function FriendsFrame_Update()
	if ( FriendsFrame.selectedTab == 1 ) then
		if ( FriendsFrame.showFriendsList ) then
			ShowFriends();
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotRight");
			FriendsFrameTitleText:SetText(FRIENDS_LIST);
			FriendsFrame_ShowSubFrame("FriendsListFrame");
		elseif ( FriendsFrame.showMutedList ) then
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
			FriendsFrameTitleText:SetText(MUTED_LIST);
			FriendsFrame_ShowSubFrame("MutedListFrame");
			MutedList_Update();
		else
			FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
			FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
			FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotLeft");
			FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-IgnoreFrame-BotRight");
			FriendsFrameTitleText:SetText(IGNORE_LIST);
			FriendsFrame_ShowSubFrame("IgnoreListFrame");
			IgnoreList_Update();
		end
	elseif ( FriendsFrame.selectedTab == 2 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\WhoFrame-BotRight");
		FriendsFrameTitleText:SetText(WHO_LIST);
		FriendsFrame_ShowSubFrame("WhoFrame");
		WhoList_Update();
	elseif ( FriendsFrame.selectedTab == 3 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\GuildFrame-BotRight");
		local guildName, title, rank = GetGuildInfo("player");
		if ( guildName ) then
			FriendsFrameTitleText:SetFormattedText(GUILD_TITLE_TEMPLATE, title, guildName);
		else 
			FriendsFrameTitleText:SetText("");
		end
		GuildStatus_Update();
		FriendsFrame_ShowSubFrame("GuildFrame");
	elseif ( FriendsFrame.selectedTab == 4 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-BotRight");
		FriendsFrameTitleText:SetText(CHAT_CHANNELS);
		FriendsFrame_ShowSubFrame("ChannelFrame");
	elseif ( FriendsFrame.selectedTab == 5 ) then
		FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
		FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
		FriendsFrameBottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft");
		FriendsFrameBottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight");
		FriendsFrameTitleText:SetText(RAID);
		FriendsFrame_ShowSubFrame("RaidFrame");
	end
end

function FriendsFrame_OnHide()
	UpdateMicroButtons();
	PlaySound("igMainMenuClose");
	SetGuildRosterSelection(0);
	GuildFrame.selectedGuildMember = 0;
	GuildFramePopup_HideAll();
	RaidInfoFrame:Hide();
	for index, value in pairs(FRIENDSFRAME_SUBFRAMES) do
		getglobal(value):Hide();
	end
end

function FriendsList_Update()
	local numFriends = GetNumFriends();
	local nameLocationText;
	local infoText;
	local name;
	local level;
	local class;
	local area;
	local connected;
	local status;
	local friendButton;

	FriendsFrame.selectedFriend = GetSelectedFriend();
	if ( numFriends > 0 ) then
		if ( FriendsFrame.selectedFriend == 0 ) then
			SetSelectedFriend(1);
			FriendsFrame.selectedFriend = GetSelectedFriend();
		end
		name, level, class, area, connected = GetFriendInfo(FriendsFrame.selectedFriend);
		if ( connected ) then
			FriendsFrameSendMessageButton:Enable();
			FriendsFrameGroupInviteButton:Enable();
		else
			FriendsFrameSendMessageButton:Disable();
			FriendsFrameGroupInviteButton:Disable();
		end
		FriendsFrameRemoveFriendButton:Enable();
	else
		FriendsFrameSendMessageButton:Disable();
		FriendsFrameGroupInviteButton:Disable();
		FriendsFrameRemoveFriendButton:Disable();
	end
	
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame);
	local friendIndex;
	for i=1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i;
		name, level, class, area, connected, status = GetFriendInfo(friendIndex);
		nameLocationText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextNameLocation");
		infoText = getglobal("FriendsFrameFriendButton"..i.."ButtonTextInfo");
		if ( not name ) then
			name = UNKNOWN
		end
		if ( connected ) then
			nameLocationText:SetFormattedText(FRIENDS_LIST_TEMPLATE, name, area, status);
			infoText:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
		else
			nameLocationText:SetFormattedText(FRIENDS_LIST_OFFLINE_TEMPLATE, name);
			infoText:SetText(UNKNOWN);
		end
		friendButton = getglobal("FriendsFrameFriendButton"..i);
		friendButton:SetID(friendIndex);
		
		-- Update the highlight
		if ( friendIndex == FriendsFrame.selectedFriend ) then
			friendButton:LockHighlight();
		else
			friendButton:UnlockHighlight();
		end
		
		if ( friendIndex > numFriends ) then
			friendButton:Hide();
		else
			friendButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameFriendsScrollFrame, numFriends, FRIENDS_TO_DISPLAY, FRIENDS_FRAME_FRIEND_HEIGHT );
end

function IgnoreList_Update()
	local numIgnores = GetNumIgnores();
	local nameText;
	local name;
	local ignoreButton;
	FriendsFrame.selectedIgnore = GetSelectedIgnore();
	if ( numIgnores > 0 ) then
		if ( FriendsFrame.selectedIgnore == 0 ) then
			SetSelectedIgnore(1);
		end
		FriendsFrameStopIgnoreButton:Enable();
	else
		FriendsFrameStopIgnoreButton:Disable();
	end

	local ignoreOffset = FauxScrollFrame_GetOffset(FriendsFrameIgnoreScrollFrame);
	local ignoreIndex;
	for i=1, IGNORES_TO_DISPLAY, 1 do
		ignoreIndex = i + ignoreOffset;
		nameText = getglobal("FriendsFrameIgnoreButton"..i.."ButtonTextName");
		nameText:SetText(GetIgnoreName(ignoreIndex));
		ignoreButton = getglobal("FriendsFrameIgnoreButton"..i);
		ignoreButton:SetID(ignoreIndex);
		-- Update the highlight
		if ( ignoreIndex == FriendsFrame.selectedIgnore ) then
			ignoreButton:LockHighlight();
		else
			ignoreButton:UnlockHighlight();
		end
		
		if ( ignoreIndex > numIgnores ) then
			ignoreButton:Hide();
		else
			ignoreButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameIgnoreScrollFrame, numIgnores, IGNORES_TO_DISPLAY, FRIENDS_FRAME_IGNORE_HEIGHT );
end

function MutedList_Update()
	local numMuted = GetNumMutes();
	local nameText;
	local name;
	local muteButton;
	FriendsFrame.selectedMute = GetSelectedMute();
	if ( numMuted > 0 ) then
		if ( FriendsFrame.selectedMute == 0 ) then
			SetSelectedMute(1);
		end
		FriendsFrameUnmuteButton:Enable();
	else
		FriendsFrameUnmuteButton:Disable();
	end

	local muteOffset = FauxScrollFrame_GetOffset(FriendsFrameMutedScrollFrame);
	local muteIndex;
	for i=1, IGNORES_TO_DISPLAY, 1 do
		muteIndex = i + muteOffset;
		nameText = getglobal("FriendsFrameMutedButton"..i.."ButtonTextName");
		nameText:SetText(GetMuteName(muteIndex));
		muteButton = getglobal("FriendsFrameMutedButton"..i);
		muteButton:SetID(muteIndex);
		-- Update the highlight
		if ( muteIndex == FriendsFrame.selectedMute ) then
			muteButton:LockHighlight();
		else
			muteButton:UnlockHighlight();
		end
		
		if ( muteIndex > numMuted ) then
			muteButton:Hide();
		else
			muteButton:Show();
		end
	end
	
	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameMutedScrollFrame, numMuted, IGNORES_TO_DISPLAY, FRIENDS_FRAME_IGNORE_HEIGHT );
end

function WhoList_Update()
	local numWhos, totalCount = GetNumWhoResults();
	local name, guild, level, race, class, zone;
	local button, buttonText, classTextColor;
	local columnTable;
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);
	local whoIndex;
	local showScrollBar = nil;
	if ( numWhos > WHOS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	WhoFrameTotals:SetText(format(GetText("WHO_FRAME_TOTAL_TEMPLATE", nil, totalCount), totalCount).."  "..displayedText);
	for i=1, WHOS_TO_DISPLAY, 1 do
		whoIndex = whoOffset + i;
		button = getglobal("WhoFrameButton"..i);
		button.whoIndex = whoIndex;
		name, guild, level, race, class, zone, classFileName = GetWhoInfo(whoIndex);
		columnTable = { zone, guild, race };

		if ( classFileName ) then
			classTextColor = RAID_CLASS_COLORS[classFileName];
		else
			classTextColor = HIGHLIGHT_FONT_COLOR;
		end
		buttonText = getglobal("WhoFrameButton"..i.."Name");
		buttonText:SetText(name);
		buttonText = getglobal("WhoFrameButton"..i.."Level");
		buttonText:SetText(level);
		buttonText = getglobal("WhoFrameButton"..i.."Class");
		buttonText:SetText(class);
		buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
		local variableText = getglobal("WhoFrameButton"..i.."Variable");
		variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)]);
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			variableText:SetWidth(95);
		else
			variableText:SetWidth(110);
		end

		-- Highlight the correct who
		if ( WhoFrame.selectedWho == whoIndex ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( whoIndex > numWhos ) then
			button:Hide();
		else
			button:Show();
		end
	end

	if ( not WhoFrame.selectedWho ) then
		WhoFrameGroupInviteButton:Disable();
		WhoFrameAddFriendButton:Disable();
	else
		WhoFrameGroupInviteButton:Enable();
		WhoFrameAddFriendButton:Enable();
		WhoFrame.selectedName = GetWhoInfo(WhoFrame.selectedWho); 
	end

	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(105, WhoFrameColumnHeader2);
		UIDropDownMenu_SetWidth(80, WhoFrameDropDown);
	else
		WhoFrameColumn_SetWidth(120, WhoFrameColumnHeader2);
		UIDropDownMenu_SetWidth(95, WhoFrameDropDown);
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(WhoListScrollFrame, numWhos, WHOS_TO_DISPLAY, FRIENDS_FRAME_WHO_HEIGHT );

	PanelTemplates_SetTab(FriendsFrame, 2);
	ShowUIPanel(FriendsFrame);
end

function GuildStatus_Update()
	-- Set the tab
	PanelTemplates_SetTab(FriendsFrame, 3);
	-- Show the frame
	ShowUIPanel(FriendsFrame);
	-- Number of players in the lowest rank
	FriendsFrame.playersInBotRank = 0;

	local numGuildMembers = GetNumGuildMembers();
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button, buttonText, classTextColor;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = name;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(GuildFrame.selectedName);
		GuildMemberDetailLevel:SetFormattedText(FRIENDS_LEVEL_TEMPLATE, level, class);
		GuildMemberDetailZoneText:SetText(zone);
		GuildMemberDetailRankText:SetText(rank);
		if ( online ) then
			GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL);
		else
			GuildMemberDetailOnlineText:SetText(GuildFrame_GetLastOnline(GetGuildRosterSelection()));
		end
		-- Update public note
		if ( CanEditPublicNote() ) then
			PersonalNoteText:SetTextColor(1.0, 1.0, 1.0);
			if ( (not note) or (note == "") ) then
				note = GUILD_NOTE_EDITLABEL;
			end
		else
			PersonalNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildMemberNoteBackground:EnableMouse(CanEditPublicNote());
		PersonalNoteText:SetText(note);
		-- Update officer note
		if ( CanViewOfficerNote() ) then
			if ( CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(CanEditOfficerNote());
			OfficerNoteText:SetText(officernote);

			-- Resize detail frame
			GuildMemberDetailOfficerNoteLabel:Show();
			GuildMemberOfficerNoteBackground:Show();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT);
		else
			GuildMemberDetailOfficerNoteLabel:Hide();
			GuildMemberOfficerNoteBackground:Hide();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT);
		end

		-- Manage guild member related buttons
		if ( CanGuildPromote() and ( rankIndex > 1 ) and ( rankIndex > (guildRankIndex + 1) ) ) then
			GuildFramePromoteButton:Enable();
		else 
			GuildFramePromoteButton:Disable();
		end
		if ( CanGuildDemote() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) and ( rankIndex ~= maxRankIndex ) ) then
			GuildFrameDemoteButton:Enable();
		else
			GuildFrameDemoteButton:Disable();
		end
		-- Hide promote/demote buttons if both disabled
		if ( GuildFrameDemoteButton:IsEnabled() == 0 and GuildFramePromoteButton:IsEnabled() == 0 ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == name) or (not online) ) then
			GuildMemberGroupInviteButton:Disable();
		else
			GuildMemberGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	else
		GuildMemberDetailFrame:Hide();
	end
	
	-- Message of the day stuff
	local guildMOTD = GetGuildRosterMOTD();
	if ( CanEditMOTD() ) then
		if ( (not guildMOTD) or (guildMOTD == "") ) then
			guildMOTD = GUILD_MOTD_EDITLABEL;
		end
		GuildFrameNotesText:SetTextColor(1.0, 1.0, 1.0);
		GuildMOTDEditButton:Enable();
	else
		GuildFrameNotesText:SetTextColor(0.65, 0.65, 0.65);
		GuildMOTDEditButton:Disable();
	end
	GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);

	-- Scrollbar stuff
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	
	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			FriendsFrame.playersInBotRank = FriendsFrame.playersInBotRank + 1;
		end
	end
	GuildFrameTotals:SetFormattedText(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers);
	GuildFrameOnlineTotals:SetFormattedText(GUILD_TOTALONLINE, onlinecount);

	-- Update global guild frame buttons
	if ( IsGuildLeader() ) then
		GuildFrameControlButton:Enable();
	else
		GuildFrameControlButton:Disable();
	end
	if ( CanGuildInvite() ) then
		GuildFrameAddMemberButton:Enable();
	else
		GuildFrameAddMemberButton:Disable();
	end


	if ( FriendsFrame.playerStatusFrame ) then
		-- Player specific info
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = getglobal("GuildFrameButton"..i);
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			if ( not online ) then
				buttonText = getglobal("GuildFrameButton"..i.."Name");
				buttonText:SetText(name);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = getglobal("GuildFrameButton"..i.."Zone");
				buttonText:SetText(zone);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = getglobal("GuildFrameButton"..i.."Level");
				buttonText:SetText(level);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
				buttonText = getglobal("GuildFrameButton"..i.."Class");
				buttonText:SetText(class);
				buttonText:SetTextColor(0.5, 0.5, 0.5);
			else
				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end

				buttonText = getglobal("GuildFrameButton"..i.."Name");
				buttonText:SetText(name);
				buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				buttonText = getglobal("GuildFrameButton"..i.."Zone");
				buttonText:SetText(zone);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = getglobal("GuildFrameButton"..i.."Level");
				buttonText:SetText(level);
				buttonText:SetTextColor(1.0, 1.0, 1.0);
				buttonText = getglobal("GuildFrameButton"..i.."Class");
				buttonText:SetText(class);
				buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(95);
			else
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(110);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			
			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(PLAYER_STATUS);
		-- If need scrollbar resize column headers
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(105, GuildFrameColumnHeader2);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(120, GuildFrameColumnHeader2);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -67);
		end
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );
		
		GuildPlayerStatusFrame:Show();
		GuildStatusFrame:Hide();
	else
		-- Guild specific info
		local year, month, day, hour;
		local yearlabel, monthlabel, daylabel, hourlabel;
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = getglobal("GuildFrameGuildStatusButton"..i);
			button.guildIndex = guildIndex;
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(guildIndex);

			getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(name);
			getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(rank);
			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(note);

			if ( online ) then
				if ( status == "" ) then
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GUILD_ONLINE_LABEL);
				else
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(status);
				end

				if ( classFileName ) then
					classTextColor = RAID_CLASS_COLORS[classFileName];
				else
					classTextColor = NORMAL_FONT_COLOR;
				end
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(1.0, 1.0, 1.0);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GuildFrame_GetLastOnline(guildIndex));
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(0.5, 0.5, 0.5);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(0.5, 0.5, 0.5);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(70);
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(85);
			end

			-- Highlight the correct who
			if ( GetGuildRosterSelection() == guildIndex ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end

			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end
		
		GuildFrameGuildListToggleButton:SetText(GUILD_STATUS);
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			WhoFrameColumn_SetWidth(75, GuildFrameGuildStatusColumnHeader3);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 284, -67);
		else
			WhoFrameColumn_SetWidth(90, GuildFrameGuildStatusColumnHeader3);
			GuildFrameGuildListToggleButton:SetPoint("LEFT", "GuildFrame", "LEFT", 307, -67);
		end
		
		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
end

function WhoFrameColumn_SetWidth(width, frame)
	if ( not frame ) then
		frame = this;
	end
	frame:SetWidth(width);
	getglobal(frame:GetName().."Middle"):SetWidth(width - 9);
end

function WhoFrameDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	for i=1, getn(WHOFRAME_DROPDOWN_LIST), 1 do
		info.text = WHOFRAME_DROPDOWN_LIST[i].name;
		info.func = WhoFrameDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function WhoFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, WhoFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(80);
	UIDropDownMenu_SetButtonWidth(24);
	UIDropDownMenu_JustifyText("LEFT", WhoFrameDropDown)
end

function WhoFrameDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(WhoFrameDropDown, this:GetID());
	WhoList_Update();
end

function FriendsFrame_OnEvent()
	if ( event == "FRIENDLIST_SHOW" ) then
		FriendsList_Update();
		FriendsFrame_Update();
	elseif ( event == "FRIENDLIST_UPDATE" ) then
		FriendsList_Update();
	elseif ( event == "IGNORELIST_UPDATE" ) then
		IgnoreList_Update();
	elseif ( event == "MUTELIST_UPDATE" ) then
		MutedList_Update();
	elseif ( event == "WHO_LIST_UPDATE" ) then
		WhoList_Update();
		FriendsFrame_Update();
	elseif ( event == "GUILD_ROSTER_UPDATE" ) then
		if ( GuildFrame:IsShown() ) then
			if ( arg1 ) then
				GuildRoster();
			end
			GuildStatus_Update();
			FriendsFrame_Update();
			GuildControlPoupFrame_Initialize();
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		if ( FriendsFrame:IsVisible() ) then
			InGuildCheck();
		end
	elseif ( event == "GUILD_MOTD") then
		CURRENT_GUILD_MOTD = arg1;
		GuildFrameNotesText:SetText(CURRENT_GUILD_MOTD);
	elseif ( event == "VOICE_CHAT_ENABLED_UPDATE" ) then
		VoiceChat_Toggle();
	end
end

function FriendsFrameFriendButton_OnClick(button)
	if ( button == "LeftButton" ) then
		SetSelectedFriend(this:GetID());
		FriendsList_Update();
	else
		local name, level, class, area, connected = GetFriendInfo(this:GetID());
		FriendsFrame_ShowDropdown(name, connected);
	end
end

function FriendsFrameIgnoreButton_OnClick()
	SetSelectedIgnore(this:GetID());
	IgnoreList_Update();
end

function FriendsFrameMuteButton_OnClick()
	SetSelectedMute(this:GetID());
	MutedList_Update();
end

function FriendsFrameWhoButton_OnClick(button)
	if ( button == "LeftButton" ) then
		WhoFrame.selectedWho = getglobal("WhoFrameButton"..this:GetID()).whoIndex;
		WhoFrame.selectedName = getglobal("WhoFrameButton"..this:GetID().."Name"):GetText();
		WhoList_Update();
	else
		local name = getglobal("WhoFrameButton"..this:GetID().."Name"):GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
end

function FriendsFrameGuildStatusButton_OnClick(button)
	if ( button == "LeftButton" ) then
		GuildFrame.previousSelectedGuildMember = GuildFrame.selectedGuildMember;
		GuildFrame.selectedGuildMember = this.guildIndex;
		GuildFrame.selectedName = getglobal(this:GetName().."Name"):GetText();
		SetGuildRosterSelection(GuildFrame.selectedGuildMember);
		-- Toggle guild details frame
		if ( GuildMemberDetailFrame:IsShown() and (GuildFrame.previousSelectedGuildMember and (GuildFrame.previousSelectedGuildMember == GuildFrame.selectedGuildMember)) ) then
			GuildMemberDetailFrame:Hide();
			GuildFrame.selectedGuildMember = 0;
			SetGuildRosterSelection(0);
		else
			GuildFramePopup_Show(GuildMemberDetailFrame);
		end
		GuildStatus_Update();
	else
		local guildIndex = this.guildIndex;
		local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
		FriendsFrame_ShowDropdown(name, online);
	end
end

function FriendsFrame_UnIgnore()
	local name;
	name = GetIgnoreName(FriendsFrame.selectedIgnore);
	DelIgnore(name);
end

function FriendsFrame_UnMute()
	local name;
	name = GetMuteName(FriendsFrame.selectedMute);
	DelMute(name);
end

function FriendsFrame_RemoveFriend()
	if ( FriendsFrame.selectedFriend ) then
		RemoveFriend(FriendsFrame.selectedFriend);
	end
end

function FriendsFrame_SendMessage()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	if ( not ChatFrameEditBox:IsShown() ) then
		ChatFrame_OpenChat("/w "..name.." ");
	else
		ChatFrameEditBox:SetText("/w "..name.." ");
	end
	ChatEdit_ParseText(ChatFrame1.editBox, 0);
end

function FriendsFrame_GroupInvite()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	InviteUnit(name);
end

function ToggleFriendsFrame(tab)
	if ( not tab ) then
		if ( FriendsFrame:IsShown() ) then
			HideUIPanel(FriendsFrame);
		else
			ShowUIPanel(FriendsFrame);
		end
	else
		-- If not in a guild don't do anything when they try to toggle the guild tab
		if ( tab == 3 and not IsInGuild() ) then
			return;
		end
		if ( tab == PanelTemplates_GetSelectedTab(FriendsFrame) and FriendsFrame:IsShown() ) then
			HideUIPanel(FriendsFrame);
			return;
		end
		PanelTemplates_SetTab(FriendsFrame, tab);
		if ( FriendsFrame:IsShown() ) then
			FriendsFrame_OnShow();
		else
			ShowUIPanel(FriendsFrame);
		end
	end
end

function WhoFrameEditBox_OnEnterPressed()
	SendWho(WhoFrameEditBox:GetText());
	WhoFrameEditBox:ClearFocus();
end

function ToggleFriendsPanel()
	local friendsTabShown =
		FriendsFrame:IsShown() and
		PanelTemplates_GetSelectedTab(FriendsFrame) == 1 and
		FriendsFrame.showFriendsList == 1;

	if ( friendsTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		FriendsFrame.showFriendsList = 1;
		FriendsFrame_Update();
		ShowUIPanel(FriendsFrame);
	end
end

function ShowWhoPanel()
	PanelTemplates_SetTab(FriendsFrame, 2);
	if ( FriendsFrame:IsShown() ) then
		FriendsFrame_OnShow();
	else
		ShowUIPanel(FriendsFrame);
	end
end

function ToggleIgnorePanel()
	local ignoreTabShown =
		FriendsFrame:IsShown() and
		PanelTemplates_GetSelectedTab(FriendsFrame) == 1 and
		FriendsFrame.showFriendsList == nil;

	if ( ignoreTabShown ) then
		HideUIPanel(FriendsFrame);
	else
		PanelTemplates_SetTab(FriendsFrame, 1);
		FriendsFrame.showFriendsList = nil;
		FriendsFrame_Update();
		ShowUIPanel(FriendsFrame);
	end
end

function WhoFrame_GetDefaultWhoCommand()
	local level = UnitLevel("player");
	local minLevel = level-3;
	if ( minLevel <= 0 ) then
		minLevel = 1;
	end
	local command = WHO_TAG_ZONE.."\""..GetRealZoneText().."\" "..minLevel.."-"..(level+3);
	return command;
end

function GuildControlPopupFrame_OnLoad()
	GuildControlPopupFrameCheckbox1Text:SetText(GUILDCONTROL_OPTION1);
	GuildControlPopupFrameCheckbox2Text:SetText(GUILDCONTROL_OPTION2);
	GuildControlPopupFrameCheckbox3Text:SetText(GUILDCONTROL_OPTION3);
	GuildControlPopupFrameCheckbox4Text:SetText(GUILDCONTROL_OPTION4);
	GuildControlPopupFrameCheckbox5Text:SetText(GUILDCONTROL_OPTION5);
	GuildControlPopupFrameCheckbox6Text:SetText(GUILDCONTROL_OPTION6);
	GuildControlPopupFrameCheckbox7Text:SetText(GUILDCONTROL_OPTION7);
	GuildControlPopupFrameCheckbox8Text:SetText(GUILDCONTROL_OPTION8);
	GuildControlPopupFrameCheckbox9Text:SetText(GUILDCONTROL_OPTION9);
	GuildControlPopupFrameCheckbox10Text:SetText(GUILDCONTROL_OPTION10);
	GuildControlPopupFrameCheckbox11Text:SetText(GUILDCONTROL_OPTION11);
	GuildControlPopupFrameCheckbox12Text:SetText(GUILDCONTROL_OPTION12);
	GuildControlPopupFrameCheckbox13Text:SetText(GUILDCONTROL_OPTION13);
	GuildControlPopupFrameCheckbox14Text:SetText(GUILDCONTROL_OPTION14);
	GuildControlTabPermissionsViewTabText:SetText(GUILDCONTROL_VIEW_TAB);
	GuildControlTabPermissionsDepositItemsText:SetText(GUILDCONTROL_DEPOSIT_ITEMS);
	ClearPendingGuildBankPermissions();
end

--Need to call this function on an event since the guildroster is not available during OnLoad()
function GuildControlPoupFrame_Initialize()
	if ( GuildControlPopupFrame.initialized ) then
		return;
	end
	GuildControlSetRank(1);
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	UIDropDownMenu_SetText(GuildControlGetRankName(1), GuildControlPopupFrameDropDown);
	-- Select tab 1
	GuildBankTabPermissionsTab_OnClick(1);

	GuildControlPopupFrame:SetScript("OnEvent", GuildControlPopupFrame_OnEvent);
	GuildControlPopupFrame.initialized = 1;
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
end

function GuildControlPopupFrame_OnShow()
	FriendsFrame.guildControlShow = 1;
	GuildControlPopupAcceptButton:Disable();
	-- Update popup
	GuildControlPopupframe_Update();

	UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth() + GuildControlPopupFrame:GetWidth();
	UpdateUIPanelPositions(FriendsFrame);
	GuildControlPopupFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
end

function GuildControlPopupFrame_OnEvent (self, event, ...)
	local rank
	for i = 1, GuildControlGetNumRanks() do
		rank = GuildControlGetRankName(i);
		if ( GuildControlPopupFrame.rank and rank == GuildControlPopupFrame.rank ) then
			UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, i);
			UIDropDownMenu_SetText(rank, GuildControlPopupFrameDropDown);
		end
	end
	
	GuildControlPopupframe_Update()
end

function GuildControlPopupFrame_OnHide()
	FriendsFrame.guildControlShow = 0;

	UIPanelWindows["FriendsFrame"].width = FriendsFrame:GetWidth();
	UpdateUIPanelPositions();

	GuildControlPopupFrame.goldChanged = nil;
	GuildControlPopupFrame:UnregisterEvent("GUILD_ROSTER_UPDATE");
end

function GuildControlPopupframe_Update()
	-- Update permission flags
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	local rankID = UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(rankID));
	if ( GuildControlPopupFrame.previousSelectedRank and GuildControlPopupFrame.previousSelectedRank ~= rankID ) then
		ClearPendingGuildBankPermissions();
	end
	GuildControlPopupFrame.previousSelectedRank = rankID;

	--If rank to modify is guild master then gray everything out
	if ( IsGuildLeader() and rankID == 1 ) then
		GuildBankTabLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		OptionsFrame_DisableCheckBox(GuildControlTabPermissionsDepositItems);
		OptionsFrame_DisableCheckBox(GuildControlTabPermissionsViewTab);
		GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBox:SetNumeric(nil);
		GuildControlWithdrawItemsEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBox:SetText(UNLIMITED);
		GuildControlWithdrawItemsEditBox:ClearFocus();
		GuildControlWithdrawItemsEditBoxMask:Show();
		GuildControlWithdrawGoldText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetNumeric(nil);
		GuildControlWithdrawGoldEditBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetText(UNLIMITED);
		GuildControlWithdrawGoldEditBox:ClearFocus();
		GuildControlWithdrawGoldEditBoxMask:Show();
		OptionsFrame_DisableCheckBox(GuildControlPopupFrameCheckbox14);
	else
		GuildBankTabLabel:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		OptionsFrame_EnableCheckBox(GuildControlTabPermissionsViewTab);
		GuildControlTabPermissionsWithdrawItemsText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBox:SetNumeric(1);
		GuildControlWithdrawItemsEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GuildControlWithdrawItemsEditBoxMask:Hide();
		GuildControlWithdrawGoldText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBox:SetNumeric(1);
		GuildControlWithdrawGoldEditBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GuildControlWithdrawGoldEditBoxMask:Hide();
		OptionsFrame_EnableCheckBox(GuildControlPopupFrameCheckbox14);

		-- Update tab specific info
		local viewTab, canDeposit, numWithdrawals = GetGuildBankTabPermissions(GuildControlPopupFrameTabPermissions.selectedTab);
		if ( rankID == 1 ) then
			--If is guildmaster then force checkboxes to be selected
			viewTab = 1;
			canDeposit = 1;
		end
		GuildControlTabPermissionsViewTab:SetChecked(viewTab);
		GuildControlTabPermissionsDepositItems:SetChecked(canDeposit);
		GuildControlWithdrawItemsEditBox:SetText(numWithdrawals);
		local goldWithdrawLimit = GetGuildBankWithdrawLimit();
		-- Only write to the editbox if the value hasn't been changed by the player
		if ( not GuildControlPopupFrame.goldChanged ) then
			if ( goldWithdrawLimit >= 0 ) then
				GuildControlWithdrawGoldEditBox:SetText(goldWithdrawLimit);
			else
				-- This is for the guild leader who defaults to -1
				GuildControlWithdrawGoldEditBox:SetText(MAX_GOLD_WITHDRAW);
			end
		end
		GuildControlPopup_UpdateDepositCheckBox();
	end
	
	--Only show available tabs
	local tab;
	local numTabs = GetNumGuildBankTabs();
	local name;
	for i=1, MAX_GUILDBANK_TABS do
		name = GetGuildBankTabInfo(i);
		tab = getglobal("GuildBankTabPermissionsTab"..i);
		
		if ( i <= numTabs ) then
			tab:Show();
			tab.tooltip = name;
			permissionsTabBackground = getglobal("GuildBankTabPermissionsTab"..i.."Background");
			permissionsText = getglobal("GuildBankTabPermissionsTab"..i.."Text");
			if (  GuildControlPopupFrameTabPermissions.selectedTab == i ) then
				tab:LockHighlight();
				permissionsTabBackground:SetTexCoord(0, 1.0, 0, 1.0);
				permissionsTabBackground:SetHeight(32);
				permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -3);
			else
				tab:UnlockHighlight();
				permissionsTabBackground:SetTexCoord(0, 1.0, 0, 0.875);
				permissionsTabBackground:SetHeight(28);
				permissionsText:SetPoint("CENTER", permissionsTabBackground, "CENTER", 0, -5);
			end
			if ( IsGuildLeader() and rankID == 1 ) then
				tab:Disable();
				tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			else
				tab:Enable();
				tab:SetDisabledTextColor(nil, nil, nil);
			end
		else
			tab:Hide();
		end
	end
end

function GuildControlPopupAcceptButton_OnClick()
	local amount = GuildControlWithdrawGoldEditBox:GetText();
	if(amount and amount ~= "" and amount ~= UNLIMITED and tonumber(amount) > 0) then
		SetGuildBankWithdrawLimit(amount);
	else
		SetGuildBankWithdrawLimit(0);
	end
	SavePendingGuildBankTabPermissions()
	GuildControlSaveRank(GuildControlPopupFrameEditBox:GetText());
	GuildStatus_Update();
	GuildControlPopupAcceptButton:Disable();
	UIDropDownMenu_SetText(GuildControlPopupFrameEditBox:GetText(), GuildControlPopupFrameDropDown);
	GuildControlPopupFrame:Hide();
	ClearPendingGuildBankPermissions();
end

function GuildControlPopupFrameDropDown_OnLoad()
	UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
	UIDropDownMenu_SetWidth(160);
	UIDropDownMenu_SetButtonWidth(54);
	UIDropDownMenu_JustifyText("LEFT", GuildControlPopupFrameDropDown);
end

function GuildControlPopupFrameDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	for i=1, GuildControlGetNumRanks(), 1 do
		info.text = GuildControlGetRankName(i);
		info.func = GuildControlPopupFrameDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function GuildControlPopupFrameDropDownButton_OnClick()
	local rank = this:GetID();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, rank);	
	GuildControlSetRank(rank);
	GuildControlPopupFrame.rank = GuildControlGetRankName(rank);
	GuildControlPopupFrame.goldChanged = nil;
	GuildControlPopupframe_Update();
	GuildControlPopupFrameAddRankButton_OnUpdate();
	GuildControlPopupFrameRemoveRankButton_OnUpdate();
	GuildControlPopupAcceptButton:Disable();
end

function GuildControlCheckboxUpdate(...)
	local checkbox;
	for i=1, select("#", ...), 1 do
		checkbox = getglobal("GuildControlPopupFrameCheckbox"..i)
		if ( checkbox ) then
			checkbox:SetChecked(select(i, ...));
		else
			message("GuildControlPopupFrameCheckbox"..i.." does not exist!");
		end
	end
end

function GuildControlPopupFrameAddRankButton_OnUpdate()
	if ( GuildControlGetNumRanks() >= 10 ) then
		GuildControlPopupFrameAddRankButton:Disable();
	else
		GuildControlPopupFrameAddRankButton:Enable();
	end
end

function GuildControlPopupFrameRemoveRankButton_OnClick()
	GuildControlDelRank(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
	GuildControlPopupFrame.rank = GuildControlGetRankName(1);
	GuildControlSetRank(1);
	GuildStatus_Update();
	UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, 1);
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(1));
	GuildControlCheckboxUpdate(GuildControlGetRankFlags());
	CloseDropDownMenus();
	-- Set this to call guildroster in the next frame
	--GuildRoster();
	--GuildControlPopupFrame.update = 1;
end

function GuildControlPopupFrameRemoveRankButton_OnUpdate()
	if ( (UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown) == GuildControlGetNumRanks()) and (GuildControlGetNumRanks() > 5) ) then
		GuildControlPopupFrameRemoveRankButton:Show();
		if ( FriendsFrame.playersInBotRank > 0 ) then
			GuildControlPopupFrameRemoveRankButton:Disable();
		else
			GuildControlPopupFrameRemoveRankButton:Enable();
		end
	else
		GuildControlPopupFrameRemoveRankButton:Hide();
	end
end

function GuildControlPopup_UpdateDepositCheckBox()
	if(GuildControlTabPermissionsViewTab:GetChecked()) then
		OptionsFrame_EnableCheckBox(GuildControlTabPermissionsDepositItems);
	else
		OptionsFrame_DisableCheckBox(GuildControlTabPermissionsDepositItems);
	end
end

function InGuildCheck()
	if ( not IsInGuild() ) then
		PanelTemplates_DisableTab( FriendsFrame, 3 );
		if ( FriendsFrame.selectedTab == 3 ) then
			FriendsFrame.selectedTab = 1;
			FriendsFrame_Update();
		end
	else
		PanelTemplates_EnableTab( FriendsFrame, 3 );
		FriendsFrame_Update();
	end
end

function GuildFrameGuildListToggleButton_OnClick()
	if ( FriendsFrame.playerStatusFrame ) then
		FriendsFrame.playerStatusFrame = nil;
	else
		FriendsFrame.playerStatusFrame = 1;		
	end
	GuildStatus_Update();
end

function GuildFrameControlButton_OnUpdate()
	if ( FriendsFrame.guildControlShow == 1 ) then
		GuildFrameControlButton:LockHighlight();		
	else
		GuildFrameControlButton:UnlockHighlight();
	end
	-- Janky way to make sure a change made to the guildroster will reflect in the guildroster call
	if ( GuildControlPopupFrame.update == 1 ) then
		GuildControlPopupFrame.update = 2;
	elseif ( GuildControlPopupFrame.update == 2 ) then
		GuildRoster();
		GuildControlPopupFrame.update = nil;
	end
end

function GuildFrame_GetLastOnline(guildIndex)
	return RecentTimeDate( GetGuildRosterLastOnline(guildIndex) );
end

function ToggleGuildInfoFrame()
	if ( GuildInfoFrame:IsShown() ) then
		GuildInfoFrame:Hide();
	else
		GuildFramePopup_Show(GuildInfoFrame);
	end
end

function GuildBankTabPermissionsTab_OnClick(tab)
	GuildControlPopupFrameTabPermissions.selectedTab = tab;
	GuildControlPopupframe_Update();
end

-- Functions to allow canceling
function ClearPendingGuildBankPermissions()
	for i=1, MAX_GUILDBANK_TABS do
		PENDING_GUILDBANK_PERMISSIONS[i] = {};
	end
end

function SetPendingGuildBankTabPermissions(tab, id, checked)
	if ( not checked ) then
		checked = 0;
	end
	PENDING_GUILDBANK_PERMISSIONS[tab][id] = checked;
end

function SetPendingGuildBankTabWithdraw(tab, amount)
	PENDING_GUILDBANK_PERMISSIONS[tab]["withdraw"] = amount;
end

function SavePendingGuildBankTabPermissions()
	for index, value in pairs(PENDING_GUILDBANK_PERMISSIONS) do
		for i=1, 2 do
			if ( value[i] ) then
				SetGuildBankTabPermissions(index, i, value[i]);
			end
		end
		if ( value["withdraw"] ) then
			SetGuildBankTabWithdraw(index, value["withdraw"]);
		end
	end
end

-- Guild event log functions
function ToggleGuildEventLog()
	if ( GuildEventLogFrame:IsShown() ) then
		GuildEventLogFrame:Hide();
	else
		GuildFramePopup_Show(GuildEventLogFrame);
--		QueryGuildEventLog();
	end
end

function GuildEventLog_Update()
	local numEvents = GetNumGuildEvents();
	local type, player1, player2, rank, year, month, day, hour;
	local msg;
	GuildEventMessageFrame:Clear();
	for i=1, numEvents do
		type, player1, player2, rank, year, month, day, hour = GetGuildEventInfo(i);
		if ( not player1 ) then
			player1 = UNKNOWN;
		end
		if ( not player2 ) then
			player2 = UNKNOWN;
		end
		if ( type == "invite" ) then
			msg = format(GUILDEVENT_TYPE_INVITE, player1, player2);
		elseif ( type == "join" ) then
			msg = format(GUILDEVENT_TYPE_JOIN, player1);
		elseif ( type == "promote" ) then
			msg = format(GUILDEVENT_TYPE_PROMOTE, player1, player2, rank);
		elseif ( type == "demote" ) then
			msg = format(GUILDEVENT_TYPE_DEMOTE, player1, player2, rank);
		elseif ( type == "remove" ) then
			msg = format(GUILDEVENT_TYPE_REMOVE, player1, player2);
		elseif ( type == "quit" ) then
			msg = format(GUILDEVENT_TYPE_QUIT, player1);
		end
		if ( msg ) then
			GuildEventMessageFrame:AddMessage( msg.."|cff009999   "..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)) );
		end
	end
	FauxScrollFrame_Update(GuildEventLogScrollFrame, numEvents, MAX_EVENTS_SHOWN, GUILDEVENT_TRANSACTION_HEIGHT );
end

function GuildEventLogScroll()
	local offset = FauxScrollFrame_GetOffset(GuildEventLogScrollFrame);
	GuildEventMessageFrame:SetScrollOffset(offset);
	FauxScrollFrame_Update(GuildEventLogScrollFrame, GetNumGuildEvents(), MAX_EVENTS_SHOWN, GUILDEVENT_TRANSACTION_HEIGHT );
end

GUILDFRAME_POPUPS = {
	"GuildEventLogFrame",
	"GuildInfoFrame",
	"GuildMemberDetailFrame",
	"GuildControlPopupFrame",
};

function GuildFramePopup_Show(frame)
	local name = frame:GetName();
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		if ( name ~= value ) then
			getglobal(value):Hide();
		end
	end
	frame:Show();
end

function GuildFramePopup_HideAll()
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		getglobal(value):Hide();
	end
end