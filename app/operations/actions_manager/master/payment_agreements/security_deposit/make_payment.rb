class ActionsManager::Master::PaymentAgreements::SecurityDeposit::MakePayment < ActionsManager::Master::Base

  register_handle :security_deposit_make_payment
  register_actions [:make_payment]

  def initialize(user=nil, params=nil)
    super
    result = ::PaymentAgreements::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.security_deposit = result.security_deposits.find_by_id(params[:security_deposit_id])
    if security_deposit.blank?
      add_message :error, 'Security deposit not found'
      return
    end
  end

  def make_payment
    true
  end

end