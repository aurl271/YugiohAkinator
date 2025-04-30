--モザイク・マンティコア
function c8483333.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8483333,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c8483333.spcon)
	e1:SetTarget(c8483333.sptg)
	e1:SetOperation(c8483333.spop)
	c:RegisterEffect(e1)
	if not c8483333.global_check then
		c8483333.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c8483333.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_MSET)
		Duel.RegisterEffect(ge2,0)
	end
end
function c8483333.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsCode(8483333) and tc:IsSummonType(SUMMON_TYPE_ADVANCE) then
			if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
				tc:RegisterFlagEffect(8483333,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,Duel.GetTurnCount())
			else
				tc:RegisterFlagEffect(8483333,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,Duel.GetTurnCount())
			end
		end
		tc=eg:GetNext()
	end
end
function c8483333.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(8483333)~=0 and e:GetHandler():GetFlagEffectLabel(8483333)~=Duel.GetTurnCount() and Duel.GetTurnPlayer()==tp
end
function c8483333.spfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SUMMON) and c:GetReasonCard()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c8483333.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetMaterial():Filter(c8483333.spfilter,nil,e,tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
function c8483333.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local c=e:GetHandler()
	local g=c:GetMaterial():Filter(c8483333.spfilter,nil,e,tp,c)
	if g:GetCount()>0 then
		if g:GetCount()>ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=g:Select(tp,ft,ft,nil)
		end
		local tc=g:GetFirst()
		while tc do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			tc=g:GetNext()
		end
		Duel.SpecialSummonComplete()
	end
end
