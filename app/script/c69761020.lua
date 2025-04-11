--Ｓ－Ｆｏｒｃｅ ショウダウン
function c69761020.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69761020+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c69761020.target)
	c:RegisterEffect(e1)
end
function c69761020.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c69761020.thtg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	--Special Summon
	local b1=c69761020.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	--Add from GY
	local b2=c69761020.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(69761020,0),aux.Stringid(69761020,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(69761020,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(69761020,1))+1
	end
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		e:SetOperation(c69761020.spop)
		c69761020.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c69761020.thop)
		c69761020.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function c69761020.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c69761020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c69761020.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c69761020.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c69761020.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
end
function c69761020.thfilter(c)
	return c:IsSetCard(0x156) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c69761020.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c69761020.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c69761020.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c69761020.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c69761020.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end