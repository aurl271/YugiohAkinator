--サイバー・ダーク・キメラ
function c5370235.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5370235,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5370235)
	e1:SetCost(c5370235.thcost)
	e1:SetTarget(c5370235.thtg)
	e1:SetOperation(c5370235.thop)
	c:RegisterEffect(e1)
	--Send GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5370235,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5370235+1)
	e2:SetTarget(c5370235.tgtg)
	e2:SetOperation(c5370235.tgop)
	c:RegisterEffect(e2)
end
function c5370235.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
function c5370235.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c5370235.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c5370235.thfilter(c)
	return c:IsCode(37630732) and c:IsAbleToHand()
end
function c5370235.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c5370235.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c5370235.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(c5370235.fltg)
	e1:SetValue(c5370235.fuslimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--ex material
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(5370235,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHAIN_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c5370235.chain_target)
	e2:SetOperation(c5370235.chain_operation)
	e2:SetValue(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION))
	Duel.RegisterEffect(e2,tp)
end
function c5370235.exfilter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function c5370235.exfilter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)
end
function c5370235.chain_target(e,te,tp)
	local g1=Duel.GetMatchingGroup(c5370235.exfilter1,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil,te)
	local g2=Duel.GetMatchingGroup(c5370235.exfilter2,tp,LOCATION_GRAVE,0,nil,te)
	if g1 and g2 then
	g1:Merge(g2) end
	return g1
end
function c5370235.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	local ftc1=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local ftc2=mat:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.Remove(ftc1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.SendtoGrave(ftc2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	e:Reset()
end
function c5370235.mtval(e,c)
	if not c then return false end
	return c:IsType(TYPE_FUSION)
end
function c5370235.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c5370235.fltg(e,c)
	return not (c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsSetCard(0x93))
end
function c5370235.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end
function c5370235.tgfilter(c,tp)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_MONSTER) and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode()) and c:IsAbleToGrave()
end
function c5370235.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c5370235.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c5370235.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c5370235.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end