class Streamsets::Transactions::Payments < BaseOperation
	attr_accessor :payments

  def pre_validate

  end

  def init
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.failure?
      add_message :error, op.messages[:error]
      return
    end
    ticket_type = params[:ticket_type] || ['invoice', 'purchase_order', "beneficiary", nil]
	  bank_payment_requests = op.payment_requests.where(ticket_type: ticket_type)
	  payment_order_ids = bank_payment_requests.pluck(:payment_order_id)

	  self.payments = Payment.where(payment_order_id: payment_order_ids)
  end

  def success
  	params[:payments] = self.payments
  	Streamsets::Transactions::PaymentsPresenter.new(user, params, messages)
  end

  class Streamsets::Transactions::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
  	attr_accessor :payments, :paginated_payments

  	def init
  		self.payments = params[:payments].include_for_streamsets
  		page = params[:page] || 1
  		per_page = params[:per_page] || 30
  		self.paginated_payments = self.payments.order(payment_order_id: :desc).paginate(page: page, per_page: per_page)
  	end

  end

end