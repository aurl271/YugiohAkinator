--アタック・リフレクター・ユニット
function c91989718.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c91989718.cost)
	e1:SetTarget(c91989718.target)
	e1:SetOperation(c91989718.activate)
	c:RegisterEffect(e1)
end
function c91989718.cfilter(c,tp)
	return c:IsCode(70095154) and Duel.GetMZoneCount(tp,c)>0
end
function c91989718.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function c91989718.spfilter(c,e,tp)
	return c:IsCode(68774379) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function c91989718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			if not Duel.CheckReleaseGroup(tp,c91989718.cfilter,1,nil,tp) then return false end
		else
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		end
		return Duel.IsExistingMatchingCard(c91989718.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local g=Duel.SelectReleaseGroup(tp,c91989718.cfilter,1,1,nil,tp)
		Duel.Release(g,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c91989718.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c91989718.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
