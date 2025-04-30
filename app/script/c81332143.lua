--友情 YU－JYO
function c81332143.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c81332143.activate)
	c:RegisterEffect(e1)
end
function c81332143.filter(c)
	return c:IsCode(14731897) and not c:IsPublic()
end
function c81332143.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	if Duel.IsExistingMatchingCard(c81332143.filter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(81332143,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,c81332143.filter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		opt=1
	end
	if opt==0 then
		opt=Duel.SelectOption(1-tp,aux.Stringid(81332143,0),aux.Stringid(81332143,1))
	else
		opt=Duel.SelectOption(1-tp,aux.Stringid(81332143,0))
	end
	if opt==0 then
		local lp=math.ceil((Duel.GetLP(tp)+Duel.GetLP(1-tp))/2)
		Duel.SetLP(tp,lp)
		Duel.SetLP(1-tp,lp)
	end
end
