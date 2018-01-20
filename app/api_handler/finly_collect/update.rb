class FinlyCollect::Update < FinlyCollect::Base

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:account_number).present?
      add_message :error, 'Account Number not found'
      return
    end
  end

  def post_params
    params&.permit(:maximum_amount, :minimum_transaction_amount,
                   :maximum_transaction_amount, :exact_transaction_amount,
                   :allowed_transaction_count,
                   :current_account, :savings_account,
                   :neft, :imps, :rtgs, :upi, :date_after,
                   :date_before, :date_on)
  end

  def http_request_type
    :patch
  end

  def path
    "#{super}/#{params[:account_number]}"
  end

end