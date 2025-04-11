--光と闇の洗礼
function c69542930.initial_effect(c)
	aux.AddCodeList(c,46986414)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c69542930.cost)
	e1:SetTarget(c69542930.target)
	e1:SetOperation(c69542930.activate)
	c:RegisterEffect(e1)
end
function c69542930.cfilter(c,tp)
	return c:IsCode(46986414) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
end
function c69542930.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c69542930.cfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c69542930.cfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c69542930.filter(c,e,tp)
	return c:IsCode(40737112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c69542930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c69542930.filter,tp,0x13,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function c69542930.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69542930.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
