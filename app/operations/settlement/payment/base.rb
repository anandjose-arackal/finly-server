class Settlement::Payment::Base < Settlement::Base
  attr_accessor :payment

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
    params.require(:payment).permit(:from_cash_in_hand, :from_outside_finly, :amount, :date, :note,
                                    :currency_id, :total, :initiating_account_id, :initiating_account_type,
                                    from_reimbursement_card: [:id, :amount])
  end

  def success
    Settlement::Payment::Base::Presenter.new(user, self.payment, messages)
  end
end