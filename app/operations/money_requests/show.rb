class MoneyRequests::Show < MoneyRequests::Base


  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EMoneyRequests::Unset.(user, params)
    end
  end

end