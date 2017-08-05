class Settlement::Payment::Base < Settlement::Base
  attr_accessor :payment, :payment_request, :amount, :currency_id

  def init_payment_request(payment_type_id, payment_purpose_id)
    # Add Company Balance for the particular company
    self.payment_request = PaymentRequest.(user, nil, to_user.cash_on_hand.class.name, PaymentType.find_by(id: payment_type_id)&.name, payment_purpose_id)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, to_user.cash_on_hand, amount))
  end

  class Settlement::Payment::Base::Presenter < Settlement::Base::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

  def pre_validate
    super()
    if params[:payment][:currency_id].blank? # temporary, will be changed once currencies are implemented
      params[:payment][:currency_id] = 1
    end
  end

  def payment_params
    params.require(:payment).permit(:from_cash_in_hand, :from_outside_finly, :amount, :note, :date,
                                    :currency_id, :total, :initiating_account_id, :initiating_account_type,
                                    from_reimbursement_card: [:id, :amount], reimbursement_bank_account: [:amount])
  end

  def success
    Settlement::Payment::Base::Presenter.new(user, {payment: self.payment}, messages)
  end
end
