class Card::Configuration::CardRestriction::Base < Card::Base

	attr_accessor :budget_params, :card

	class Card::Configuration::CardRestriction::Base::RestrictionPresenter < BaseOperation::BasePresenter::SuccessPresenter	

		attr_accessor :restriction

		def init
			self.restriction = params[:restriction]
		end
	end

	def init
		# todo - temporary, need to figure out am index method for card.
		id = params[:card_id] || params[:id]
		self.card = Card.find_by(id)
	end

	def budget_restriction_params
		params.require(:budget_restriction).permit(:period_id, :card_id, amount_attributes: [:value, :currency_id])
	end

	def transaction_restriction_params
	   	params.require(:transaction_restriction).permit(:count, :card_id, :period_id)
	end

	def success
		Card::Configuration::CardRestriction::Base::RestrictionPresenter.new(user, {restriction: restriction}, messages)
	end


end