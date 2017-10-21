  class FinlyCollect::Create < FinlyCollect::Base
  attr_accessor :virtual_account

  def post_params
    params&.permit(:account_number,
                   :maximum_amount, :minimum_transaction_amount,
                   :maximum_transaction_amount, :exact_transaction_amount,
                   :allowed_transaction_count,
                   :current_account, :savings_account,
                   :neft, :imps, :rtgs, :upi, :date_after,
                   :date_before, :date_on)
  end

  def success
    params[:account_number] = self.parsed_response[:account_number]
    FinlyCollect::Create::Presenter.new(user, params, messages)
  end

  class FinlyCollect::Create::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :account_number

    def init
      self.account_number = params[:account_number]
    end

  end

end