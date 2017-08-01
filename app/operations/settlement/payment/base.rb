class Settlement::Payment::Base < Settlement::Base
  attr_accessor :payment, :payment_request, :amount, :currency_id

  def init_payment_request(payment_type_id)
    self.payment_request = PaymentRequest.new
    payment_request.initiating_user_id = user.id
    payment_request.company_id = user.company_id
    payment_request.payment_order_type_id = PaymentOrderType.id_for(:outside_finly)
    payment_request.scheduled_at = Date.today # proxy for executing the request right away
    payment_request.synchronous = true
    payment_request.payment_items = [
        {
            initiating_user_id: user.id,
            receiving_user_id: to_user.id,
            initiating_account_id: nil,
            initiating_account_type: "OutsideFinly",
            receiving_account_id: to_user.cash_on_hand.id,
            receiving_account_type: "CashOnHand",
            payment_type_id: payment_type_id,
            date: Date.today,
            amount_attributes: {
                value: amount,
                currency_id: currency_id
            }
        }
    ]
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