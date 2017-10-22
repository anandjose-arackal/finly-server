class FinlyCollect::Destroy < FinlyCollect::Base

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:account_number).present?
      add_message :error, 'Account Number not found'
      return
    end
  end

  def http_request_type
    :delete
  end

  def path
    "#{super}/#{params[:account_number]}"
  end

end