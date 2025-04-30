--魔道騎竜カース・オブ・ドラゴン
function c72064891.initial_effect(c)
	aux.AddCodeList(c,66889139)
	--fusion material
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),c72064891.ffilter,true)
	c:EnableReviveLimit()
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72064891,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,72064891)
	e1:SetCondition(c72064891.thcon)
	e1:SetTarget(c72064891.thtg)
	e1:SetOperation(c72064891.thop)
	c:RegisterEffect(e1)
	--ex material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72064891,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHAIN_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c72064891.chain_target)
	e2:SetOperation(c72064891.chain_operation)
	e2:SetValue(c72064891.exfilter)
	c:RegisterEffect(e2)
end
function c72064891.ffilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)
end
function c72064891.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c72064891.thfilter(c)
	return aux.IsCodeListed(c,66889139) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c72064891.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72064891.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c72064891.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c72064891.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c72064891.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c72064891.exfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_DRAGON)
end
function c72064891.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function c72064891.filter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)
end
function c72064891.chain_target(e,te,tp)
	local g1=Duel.GetMatchingGroup(c72064891.filter1,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil,te)
	local g2=Duel.GetMatchingGroup(c72064891.filter2,tp,LOCATION_GRAVE,0,nil,te)
	if g1 and g2 then
	g1:Merge(g2) end
	return g1
end
function c72064891.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	local ftc1=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local ftc2=mat:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.Remove(ftc1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.SendtoGrave(ftc2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
end
