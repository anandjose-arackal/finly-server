
class Card::Configuration::CardRestriction::Budget::Create < Card::Configuration::CardRestriction::Base

	attr_accessor :restriction

  def authorized_user_types
  	[:company_admin]		
  end	

  def pre_validate
 	if user.blank? or params.blank?
 	  messages[:error] << "Invalid parameters."
   	end
  end

  def init
  	super()
 	self.budget_params = budget_restriction_params
  end

  def validate
 	
  end

  def authorize
   	unless user.company_admin?
 	  raise_unauthorized_exception
  	end 	
  end

  def process
  	self.restriction = card.card_budget_restrictions.build(budget_params)
  	unless restriction.save
  		messages[:error] = restriciton.errors.full_messages
  	end		
  end

  def post_process
  	# nothing for now
  end

  def success
  	Card::Configuration::CardRestriction::Base::RestrictionPresenter.new(user, {restriction: restriction}, messages)
  end


end