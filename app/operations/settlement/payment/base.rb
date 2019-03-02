class Settlement::Payment::Base < Settlement::Base
  attr_accessor :payment, :payment_request, :amount, :currency_id, :note

  class Settlement::Payment::Base::Presenter < Settlement::Base::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

  def init_payment_request(payment_type, payment_purpose, options = {})
    initiating_account = options[:initiating_account]
    amount = options[:amount]
    receiving_account = options[:receiving_account]
    self.payment_request = PaymentRequest.(user, initiating_account, (receiving_account&.class&.name), payment_type, payment_purpose)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, receiving_account, amount, note: self.note))
  end


  def pre_validate
    super()
    if params[:payment][:currency_id].blank? # temporary, will be changed once currencies are implemented
      params[:payment][:currency_id] = 1
    end
  end

  def payment_params
    params.require(:payment).permit(:from_cash_in_hand, :from_outside_finly, :from_bank_transfer, :amount, :note, :date,
                                    :currency_id, :total, :initiating_account_id, :initiating_account_type,
                                    :receiving_account_type, :receiving_account_id, :payment_mode,
                                    from_reimbursement_card: [:id, :amount], reimbursement_bank_account: [:amount])
  end

  def cash_advance_params
    params.delete :password
    params.permit!
  end

  def success
    Settlement::Payment::Base::Presenter.new(user, {payment: self.payment}, messages)
  end
end
