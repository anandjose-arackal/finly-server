class Card::Configuration::CardRestriction::Transaction::Create < Card::Configuration::CardRestriction::Base

	attr_accessor :rule, :transaction_rule_params

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
		self.transaction_rule_params = transaction_restriction_params
	end

	def validate
		
	end

	def authorize
		unless card 
			raise_unauthorized_exception
		end
	end

	def process
		self.rule = card.card_transaction_restrictions.build(transaction_rule_params)
		unless rule.save
			messages[:error] = rule.errors.full_messages			
		end
	end

	def post_process
		# can't think of anything for now
	end

end