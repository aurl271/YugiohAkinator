--神速の具足
function c84613836.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84613836,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_SZONE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c84613836.spcon)
	e1:SetTarget(c84613836.sptg)
	e1:SetOperation(c84613836.spop)
	c:RegisterEffect(e1)
end
function c84613836.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
function c84613836.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c84613836.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and eg:IsExists(c84613836.filter,1,nil,e,tp) end
	local g=eg:Filter(c84613836.filter,nil,e,tp)
	if g:GetCount()==1 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.SetTargetCard(g)
	else
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,ft,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.SetTargetCard(sg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c84613836.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
