class Settlement::Payment::AddCashAdvanceBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :options, :user_id
  attr_accessor :payment_param, :role, :payment, :payment_purpose, :initiating_account, :receiving_account,
                :to_user, :amount, :note, :currency_id, :payment_request,
                :destination_pocket

  def initialize

  end

  def self.call(user_id, params)
    user = user_id
    if user.present? and user.is_a?(User)
      user_id = user.id
    end
    self.new.perform(user_id, params)
  end

  def perform(user_id, params, request_store_hash=nil)
    load_request_store request_store_hash
    self.user = User.find_by id: user_id
    self.params = params
    self.run
  end

  def self.perform_async(user_id, options)
    # in case the object is passed directly instead of an id
    user_id = user_id
    if user_id.present? && user_id.is_a?(User)
      user_id = user_id.id
    end
    # calls the Sidekiq::Worker method
    super(user_id, options)
  end

  def init
    # extracting the user to whom the money request belongs
    id = (params[:id] or params[:to_user_id])
    team = User::Team::Index.(user, params)
    self.to_user = team.with_id(id).first rescue nil if team.present?
    if params.class.name == HashWithIndifferentAccess.name
      self.params = ActionController::Parameters.new(params)
    end
    self.payment_param = payment_params
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

    if self.initiating_account.blank?
      add_message :error, "Destination pocket / bank account does not exist"
      return
    end

    self.payment_purpose = :cash_advance

    # this is creating the payment request for crediting money to the bank account, if at all they choose to
    init_payment_request(:credit, payment_purpose, {amount: amount, initiating_account: self.initiating_account, receiving_account: self.receiving_account})

    destination_pocket_id = params[:destination_pocket_id]
    self.destination_pocket = UserPocket.find_by id: destination_pocket_id
  end

  def process

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request, bank_transfer_type: payment_param[:payment_mode]&.upcase})
    if op.success?
      self.payment = op.payments.first
      bank_transaction = self.payment.reload.reference_resource
      self.payment.update(destination_pocket_id: self.destination_pocket.id) # storing the original receiving account so that once the bank account transaction goes through it can be credited to cash on hand
      # only if the bank transaction has been completed, will the cash on hand be added to the user's account
      # if the payment was done through a bank transfer, create a payment request for crediting the user's cash on hand
      if self.payment_purpose == :cash_advance && bank_transaction&.completed?

        init_payment_request(:credit, :advance, {amount: amount, initiating_account: nil, receiving_account: self.destination_pocket})
        # now payment request will have the new details of money to be added - so add it to the cash on hand
        op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
        payment = op.payments.first
        # setting the reference resource for the cash on hand payment as the bank transfer payment
        payment.update(reference_resource: self.payment)
      end
      return true
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

  def init_payment_request(payment_type, payment_purpose, options = {})
    initiating_account = options[:initiating_account]
    amount = options[:amount]
    receiving_account = options[:receiving_account] || to_user.user_pockets.cash_pockets_only.find_by(id: params[:destination_pocket_id])
    self.payment_request = PaymentRequest.(user, initiating_account, (receiving_account&.class&.name), payment_type, payment_purpose)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(to_user, receiving_account, amount, note: self.note))
  end

  def payment_params
    params.require(:payment).permit(:from_cash_in_hand, :from_outside_finly, :from_bank_transfer, :amount, :note, :date,
                                    :currency_id, :total, :initiating_account_id, :initiating_account_type,
                                    :receiving_account_type, :receiving_account_id, :payment_mode,
                                    from_reimbursement_card: [:id, :amount], reimbursement_bank_account: [:amount])
  end


end