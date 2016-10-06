class Card::Configuration::CardRestriction::Budget::Update < Card::Configuration::CardRestriction::Base

	attr_accessor :budget_params

	def pre_validate
		if user.blank? or params.blank?
			messages[:error] << "Invalid parameters."
		end
	end

	def init
		super()
		self.budget_params = budget_restriction_params
		self.restriction = card.budget_restrictions.find_by(params[:restriction_id] || params[:id])
	end

	def validate
		
	end

	def authorize
		
	end

	def process
		unless restriction.update(budget_params)
			messages[:error] = restriction.errors.full_messages
		end
	end

	def post_process
		
	end
end