--ЯＲＵＭ－レイド・ラプターズ・フォース
--lua by zengsxing
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 or Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.filter1(c,e)
	return c:GetRank()>0 and c:IsFaceup() and c:IsSetCard(0xba) and c:IsCanBeEffectTarget(e)
end
function s.filter2(c,e,tp,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.fselect(g,e,tp)
	local rk=g:GetSum(Card.GetRank)
	return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then
		local res=rg:CheckSubGroup(s.fselect,2,#rg,e,tp)
		return res and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,#rg,e,tp)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetsRelateToChain()
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tg:GetCount()<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tg:GetSum(Card.GetRank))
	local sc=sg:GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		for tc in aux.Next(tg) do
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.Overlay(sc,mg)
			end
			Duel.Overlay(sc,Group.FromCards(tc))
		end
		sc:CompleteProcedure()
	end
end