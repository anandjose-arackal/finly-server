class Streamsets::Transactions::Statements < BaseOperation
	attr_accessor :payments

  def pre_validate

  end

  def init
    op = MoneyRequests::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end
	  payment_ids = op.money_requests.pluck(:payment_id)

    self.payments = Payment.where(id: payment_ids).or(Payment.where(receiving_account_type: 'UserPocket', company_id: user.company_id, created_at: Date.today.beginning_of_month..Date.today))
  end

  def success
  	params[:payments] = self.payments
  	Streamsets::Transactions::StatementsPresenter.new(user, params, messages)
  end

  class Streamsets::Transactions::StatementsPresenter < BaseOperation::BasePresenter::SuccessPresenter
  	attr_accessor :payments, :paginated_payments

  	def init
  		self.payments = params[:payments].include_for_streamsets
  		page = params[:page] || 1
  		per_page = params[:per_page] || 30
  		self.paginated_payments = self.payments.order(payment_order_id: :desc).paginate(page: page, per_page: per_page)
  	end

  end

end