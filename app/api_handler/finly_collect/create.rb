class FinlyCollect::Create < FinlyCollect::Base

  def post_params
    params&.permit(
        :account_number, :maximum_amount,
        :minimum_transaction_amount,
        :maximum_transaction_amount, :exact_transaction_amount,
        :allowed_transaction_count,
        :current_account, :savings_account,
        :neft, :imps, :rtgs, :upi, :date_after,
        :date_before, :date_on
    )
  end

end