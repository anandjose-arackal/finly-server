class MoneyRequest::Card::Credit < MoneyRequest::Base

  def authorized_user_types
    [:company_admin]
  end

  protected
  def transfer
    Card::Funds::Credit.(user, to_user: self.to_user, amount: self.amount, password: params[:password])
  end
end