# action to add a cash advance to a particular user
# params:
# to_user_id or id: user whose reports are being settled
# payment:
# amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
# currency_id: currency of the reimbursement
# note: optional note to accompany payment
# date: date of the payment

class Settlement::Payment::AddCashAdvance < Settlement::Payment::Base
  include MathUtil
  attr_accessor :money_requests, :payment_param, :role, :money_request_amounts,
                :payment, :payment_purpose, :initiating_account, :receiving_account,
                :destination_pocket, :cash_advance_param

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount].blank? or params[:payment][:amount].to_f < 0
      add_message :error, 'Amount cannot be equal to or less than 0'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
    end
  end

  def init

    # extracting the user to whom the money request belongs
    id = (params[:id] or params[:to_user_id])
    team = User::Team::Index.(user, params)
    self.to_user = team.with_id(id).first rescue nil if team.present?

    self.payment_param = payment_params
    self.cash_advance_param = cash_advance_params
    if user.admin? and admin_view?
      self.role = UserRole.id_for(:admin)
    else
      self.role = UserRole.id_for(:finance_manager)
    end

    self.amount = payment_param[:amount]
    self.note = payment_param[:note]
    self.currency_id = payment_param[:currency_id] || Currency.first.id

    # setting the initiating account based on what is sent from the front end
    self.initiating_account = retrieve_initiating_account(payment_param[:initiating_account_type])
    self.receiving_account = retrieve_receiving_account(payment_param[:receiving_account_type])

    if self.receiving_account.blank?
      add_message :error, "Destination pocket / bank account does not exist"
      return
    end

    self.payment_purpose = StringUtils.to_bool(payment_param[:receiving_account_type]) ? :cash_advance : :advance_outside_finly

    # this is creating the payment request for crediting money to the bank account, if at all they choose to
    init_payment_request(:credit, payment_purpose, {amount: amount, initiating_account: self.initiating_account, receiving_account: self.receiving_account})

    destination_pocket_id = params[:destination_pocket_id]
    self.destination_pocket = UserPocket.find_by id: destination_pocket_id
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
  end

  def validate
    unless validate_date payment_param[:date]
      # above method already adds the respective error message, so just returning
      return false
    end

    if self.destination_pocket.blank?
      add_message :error, "Destination pocket / bank account does not exist"
      return
    end
  end

  def process
    # now calling the payment processor with the payment request parameter so that it handles the payment for us
    # if it's a bank transfer, it will passed to the background (and in the same operation the user's cash on hand will be added
    # else it directly adds to the user's cash on hand and returns
    if self.payment_purpose == :advance_outside_finly
      op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request, bank_transfer_type: payment_param[:payment_mode]&.upcase})
      if op.success?
        add_message :success, "Added cash on hand"
      else
        add_message :error, op.messages[:error]
      end
    else
      op = Settlement::Payment::AddCashAdvanceBackground.call_async(user.id, self.cash_advance_param.to_h)
      # op = Settlement::Payment::AddCashAdvanceBackground.call(user.id, params)
      add_message :success, "Cash on hand credit has been initiated. Please check back in some time for the money to reflect"
      return
    end
  end

  def post_process
    if self.payment_purpose == :advance_outside_finly
      Event::ESettlement::AddCashAdvance.(user, payment: self.payment)

      # recalculating user balance history for the respective day the cash was added
      unless Date.parse(payment_param[:date]) == Date.today
        balance_history = to_user.user_balance_histories.find_by(date: payment_param[:date].to_date)
        unless balance_history.blank?
          cash_on_hand_value = balance_history.cash_on_hand_balance.value
          cash_on_hand_load = balance_history.cash_on_hand_load.value
          cash_on_hand_value += payment_param[:amount].to_f
          cash_on_hand_load += payment_param[:amount].to_f
          balance_history.update_attributes(cash_on_hand_balance_attributes: {value: cash_on_hand_value, id: balance_history.cash_on_hand_balance.id},
                                            cash_on_hand_load_attributes: {value: cash_on_hand_load, id: balance_history.cash_on_hand_load.id})
        end
      end
    end
  end

  private

  def retrieve_initiating_account(account_type)
    case account_type
      when 1, '1' # i.e. finly money
        return user.bank_wallet
      when 2, '2' # i.e. company credits
        return user.company.yes_bank_company_account
      when 3, '3' # i.e. outside Finly
        return nil
      else
        # do nothing?
    end
  end

  def retrieve_receiving_account(account_type)
    case account_type
      when 1, '1' # i.e. user's bank account
        id = payment_param[:receiving_account_id]
        return to_user.bank_accounts.find_by(id: id)
      when 2, '2' # i.e. outside of Finly
        id = params[:destination_pocket_id]
        return to_user.user_pockets.cash_pockets_only.find_by(id: id)
      else
        # do nothing?
    end
  end

end