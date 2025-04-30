--ミステリーサークル
function c24082387.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetLabel(0)
	e1:SetCost(c24082387.cost)
	e1:SetTarget(c24082387.target)
	e1:SetOperation(c24082387.activate)
	c:RegisterEffect(e1)
end
function c24082387.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c24082387.cgfilter(c)
	return c:GetOriginalLevel()>0 and c:IsAbleToGraveAsCost() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
function c24082387.fselect(c,e,tp,sg,cg)
	sg:AddCard(c)
	local res=c24082387.fgoal(e,tp,sg) or cg:IsExists(c24082387.fselect,1,sg,e,tp,sg,cg)
	sg:RemoveCard(c)
	return res
end
function c24082387.fgoal(e,tp,sg)
	if Duel.GetMZoneCount(tp,sg)>0 then
		local lv=sg:GetSum(Card.GetOriginalLevel)
		return Duel.IsExistingMatchingCard(c24082387.filter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
	else return false end
end
function c24082387.filter(c,e,tp,lv)
	return c:IsSetCard(0xc) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c24082387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(c24082387.cgfilter,tp,LOCATION_MZONE,0,nil)
	local sg=Group.CreateGroup()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return cg:IsExists(c24082387.fselect,1,nil,e,tp,sg,cg)
	end
	while true do
		local mg=cg:Filter(c24082387.fselect,sg,e,tp,cg,sg)
		if mg:GetCount()==0 or (c24082387.fgoal(e,tp,sg) and not Duel.SelectYesNo(tp,210)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=mg:Select(tp,1,1,nil)
		sg:Merge(tg)
	end
	Duel.SendtoGrave(sg,REASON_COST)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c24082387.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then Duel.Damage(tp,2000,REASON_EFFECT) return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c24082387.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetSum(Card.GetLevel))
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else Duel.Damage(tp,2000,REASON_EFFECT) end
end
