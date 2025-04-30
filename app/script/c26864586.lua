--共振装置
function c26864586.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26864586.target)
	e1:SetOperation(c26864586.activate)
	c:RegisterEffect(e1)
end
function c26864586.filter1(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
function c26864586.check(g)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1 and tc2 and tc1:IsRace(tc2:GetRace()) and tc1:IsAttribute(tc2:GetAttribute()) and not tc1:IsLevel(tc2:GetLevel())
end
function c26864586.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(c26864586.filter1,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c26864586.check,2,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:SelectSubGroup(tp,c26864586.check,false,2,2)
	Duel.SetTargetCard(sg)
end
function c26864586.filter2(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function c26864586.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c26864586.filter2,nil,e)
	if g:GetCount()==2 and aux.dlvcheck(g) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26864586,0))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		local tc=g:GetFirst()
		if tc==sc then tc=g:GetNext() end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
	end
end
