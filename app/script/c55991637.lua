--火竜の火炎弾
function c55991637.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55991637,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c55991637.condition)
	e1:SetTarget(c55991637.target)
	e1:SetOperation(c55991637.activate)
	c:RegisterEffect(e1)
end
function c55991637.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function c55991637.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c55991637.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c55991637.dfilter(c)
	return c:IsFaceup() and c:IsDefenseBelow(800)
end
function c55991637.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55991637.dfilter(chkc) end
	if chk==0 then return true end
	local opt=0
	if Duel.IsExistingTarget(c55991637.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		opt=Duel.SelectOption(tp,aux.Stringid(55991637,0),aux.Stringid(55991637,1))
	end
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(800)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,c55991637.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function c55991637.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	else
		local tc=Duel.GetFirstTarget()
		if tc and c55991637.dfilter(tc) and tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
