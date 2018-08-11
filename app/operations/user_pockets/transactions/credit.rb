class UserPockets::Credit < UserPockets::Base

  def init
    super
    self.payment_parameters = payment_params
    if user.admin? and admin_view?
      self.role = UserRole.id_for(:admin)
    else
      self.role = UserRole.id_for(:finance_manager)
    end

    self.amount = payment_parameters[:amount]
    self.note = payment_parameters[:note]
    self.currency_id = payment_parameters[:currency_id] || Currency.first.id

    # setting the initiating account based on what is sent from the front end
    self.initiating_account = retrieve_initiating_account(payment_parameters[:initiating_account_type])
    self.receiving_account = retrieve_receiving_account(payment_parameters[:receiving_account_type], self.pocket.id)
    self.payment_purpose = self.receiving_account.is_a?(BankAccount) ? :cash_advance : :advance_outside_finly
  end

  def process
    # now calling the payment processor with the payment request parameter so that it handles the payment for us
    # if it's a bank transfer, it will passed to the background (and in the same operation the user's cash pocket will be added
    # else it directly adds to the user's cash on hand and returns
    if self.payment_purpose == :advance_outside_finly
      op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request, bank_transfer_type: payment_param[:payment_mode]&.upcase})
      if op.success?
        add_message :success, "Added cash on hand"
      else
        add_message :error, op.messages[:error]
      end
    else
      op = UserPockets::AddCashAdvanceBackground.call_async(user.id, params)
      add_message :success, "Cash on hand credit has been initiated. Please check back in some time for the money to reflect"
      return
    end
  end


end