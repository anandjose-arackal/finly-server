require "#{Rails.root}/app/operations/money_request/card/transfer"

class MoneyRequest::Card::Credit < MoneyRequest::Card::Transfer

  def authorized_user_types
    [:company_admin]
  end

  protected
  def transfer
    User::PrepaidCard::Funds::Credit.(user, to_user: self.to_user, amount: self.amount, password: params[:password])
  end
end