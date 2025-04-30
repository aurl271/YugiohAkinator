--先史遺産石紋
function c50797682.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,50797682+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c50797682.condition)
	e1:SetTarget(c50797682.target)
	e1:SetOperation(c50797682.activate)
	c:RegisterEffect(e1)
end
function c50797682.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function c50797682.matfilter(c,e,tp,rank)
	return c:IsSetCard(0x70) and c:IsLevel(rank) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c50797682.xyzfilter(c,e,tp,mg)
	return c:IsSetCard(0x70) and c:IsXyzSummonable(mg,2,2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c50797682.tgfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50797682.matfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,c:GetRank()+1)
	return c:GetOriginalType()&TYPE_XYZ>0 and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and Duel.IsExistingMatchingCard(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) and c:IsCanBeEffectTarget(e)
end
function c50797682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c50797682.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingTarget(c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
end
function c50797682.rescon(sg,e,tp)
	return Duel.IsExistingMatchingCard(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function c50797682.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local rank=tc:GetRank()+1
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50797682.matfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,rank)
	local sg=g:SelectSubGroup(tp,c50797682.rescon,false,2,2,e,tp)
	if sg:GetCount()<2 then return end
	local sc=sg:GetFirst()
	while sc do
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e2)
		sc=sg:GetNext()
	end
	Duel.SpecialSummonComplete()
	Duel.AdjustAll()
	if sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	local xyzg=Duel.GetMatchingGroup(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,sg,2,2)
	if xyzg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,sg)
	end
end