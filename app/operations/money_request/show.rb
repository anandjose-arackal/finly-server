class MoneyRequest::Show < MoneyRequest::Base


  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EMoneyRequest::Unset.(user, params)
    end
  end

end