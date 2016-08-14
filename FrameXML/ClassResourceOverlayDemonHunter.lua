DemonHunterResourceOverlay = {};

function DemonHunterResourceOverlay:OnLoad()
	self.initialized = false;
	self.class = "DEMONHUNTER";
	self.powerToken = "FURY";
	self.barWidth = self.Background:GetWidth();
	self.lastFury = UnitPower("player", SPELL_POWER_FURY);
	
	ClassResourceOverlay.OnLoad(self);
end

function DemonHunterResourceOverlay:OnEvent(event, arg1, arg2)
	if (event == "PLAYER_ENTERING_WORLD") then
		self.initialized = true;
		local atlasFile = self.Bar:GetAtlas();
		local atlasInfo = { atlas=atlasFile };
		self.FeedbackFrame:Initialize(atlasInfo, "player", SPELL_POWER_FURY);
	end
	ClassResourceOverlay.OnEvent(self, event, arg1, arg2);
end

function DemonHunterResourceOverlay:UpdatePower()
	if (not self.initialized) then
		return;
	end
	local fury = UnitPower("player", SPELL_POWER_FURY);
	local maxFury = UnitPowerMax("player", SPELL_POWER_FURY);
	local furyPercent = fury / maxFury;
	self.Bar:SetWidth(furyPercent * self.barWidth);
	self.Bar:SetTexCoord(0, furyPercent, 0, 1);
	
	-- Show builder spender anim if change is more than 10%
	if ( math.abs(fury - self.lastFury) / maxFury > 0.1 ) then
		self.FeedbackFrame:StartFeedbackAnim(self.lastFury, fury);
	end
	self.lastFury = fury;
end
