
class Card::Configuration::CardRestriction::Budget::Create < Card::Configuration::CardRestriction::Base

	attr_accessor :rule

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
  	self.rule = card.card_budget_restrictions.build(budget_params)
  	unless rule.save
  		messages[:error] = rule.errors.full_messages
  	end		
  end

  def post_process
  	# nothing for now
  end

  def success
  	Card::Configuration::CardRestriction::Base::BasePresenter.new(user, params, messages)
  end


end