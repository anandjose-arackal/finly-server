class ActionsManager::Master::BankTransfer::PaymentRequest::Show < ActionsManager::Master::Base

  register_handle :payment_ticket_show
  register_actions [ :mark_as_credited, :delete, :submit, :credit, :credit_options, :add_payments, :edit_order_summary, :download_payments_file, :payments_history, :edit_payment_history, :delete_payment_history, :attachments_editable, :reject, :retract, :approve, :take_control, :return_control, :unapprove, :cancel_scheduled_payment, :retry_payment, :approve_forward, :credit_in_credit_options ]


  def input
    result = BankTransfer::PaymentRequest::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    return result.bank_payment_request
  end

  alias_method :bank_payment_request, :input

  def mark_as_credited
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        return true
      elsif bank_payment_request.approved?
        return true
      end
    end
    ############# Admin logic end ####################    

    ############# Reviewer logic start ####################
    if bank_payment_request.processing?
      if (bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end
    ############# Reviewer logic start ####################

    ############# Creditor logic start ####################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        return true
      end
    end
    ############# Creditor logic end ######################


    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
      return user.vendor_payments_admin? ? true : false
    elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
      return user.vendor_payments_admin?
    end
    ############# Initiator logic end ####################
  end

  def delete
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      bank_payment_request.open? && (bank_payment_request.owner_id == user.id)
    end
    ############# Admin logic end #######################


    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
    end
    ############# Initiator logic end ####################
  end

  def submit
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      bank_payment_request.open? && (bank_payment_request.owner_id == user.id)
    end
    ############# Admin logic end #######################

    ############# Initiator logic start #######################
    if user.vendor_payments_initiator?
      (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
    end
    ############# Initiator logic end #######################
  end

  def credit
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        return !bank_payment_request.credit_card?
      elsif bank_payment_request.approved?
          return true
      elsif bank_payment_request.credited?
        return bank_payment_request.payment_order.partially_completed?
      end
    end
    ############# Admin logic end #########################

    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.controlling_user_id == user.id)
        return !bank_payment_request.credit_card?
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        return !bank_payment_request.credit_card?
      elsif bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id
        return bank_payment_request.payment_order.partially_completed?
      end
    end
    ############# Creditor logic end #########################


    ########## Initiator logic start ######################### 
    if user.vendor_payments_initiator?
      if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
        balance = retrieve_balance(:vendor_payment_wallet, user)
        if (balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval) && !bank_payment_request.credit_card?
          return true
        elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
          return true
        end
      elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
        balance = retrieve_balance(:vendor_payment_wallet, user)
        if balance >= bank_payment_request.requested_amount_value
          return true
        elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
          return true
        end
      elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
        if bank_payment_request.payment_order.partially_completed?
          return true
        end          
      end
    end
    ########### Initiator logic end ##############################
  end

  def credit_options
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if bank_payment_request.approved?
        !bank_payment_request.credit_card?
      elsif bank_payment_request.credited?
        return bank_payment_request.payment_order.partially_completed?
      end
    end
    ############# Admin logic end #######################

    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if bank_payment_request.controlling_user_id == user.id
        balance = retrieve_balance(:vendor_payment_wallet, user)
        if (balance >= bank_payment_request.requested_amount_value) && !bank_payment_request.require_approval
          return true
        else
          if user.vendor_payments_admin?
            balance = retrieve_balance(:company_credits, user)
            return true if (balance >= bank_payment_request.requested_amount_value)
          end
        end
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        balance = retrieve_balance(:vendor_payment_wallet, user)
        if (balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval)
          return !bank_payment_request.credit_card?
        else
          if user.vendor_payments_admin?
            balance = retrieve_balance(:company_credits, user)
            if balance >= bank_payment_request.requested_amount_value
              return !bank_payment_request.credit_card?
            end
          end
        end
      elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
        return bank_payment_request.payment_order.partially_completed?
      end
    end
    ############# Creditor logic end ###########################

    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
        return (credit && !bank_payment_request.credit_card?)
      elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
        return !bank_payment_request.credit_card?    
      elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
        if bank_payment_request.payment_order.partially_completed?
          return true
        end
      end
    end
    ############# Initiator logic end ####################
  end

  def add_payments
  end

  def edit_order_summary
    (user.vendor_payments_initiator?) && (bank_payment_request.open? || bank_payment_request.retracted?)
  end

  def download_payments_file
  end

  def payments_history
  end

  def edit_payment_history
  end

  def delete_payment_history
  end

  def attachments_editable

    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)

      end
    end
    ############# Admin logic end #########################


    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        return true
      end
    end
    ############# Creditor logic end #########################


    ############# Initiator logic start ####################
      if user.vendor_payments_initiator?
        (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
      end
    ############ Initiator logic end ########################
  end

  def reject
    ############# Admin logic start #########################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end
    ############# Admin logic end #########################

    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        return true
      end
    end
    ############# Creditor logic end #########################
  end

  def retract
    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      if (bank_payment_request.processing? && bank_payment_request.owner_id == user.id)
        return true
      elsif bank_payment_request.approved? && bank_payment_request.owner_id == user.id
        return true
      end
    end
    ############# Initiator logic end ####################
  end

  def approve
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end 
    ############# Admin logic end ####################


    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.controlling_user_id == user.id)
        return true
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if (bank_payment_request.controlling_user_id == user.id) && bank_payment_request.processing?
        return true
      end
    end
    ############# Creditor logic end #########################

  end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      return true if bank_payment_request.processing?
    end
    ############# Admin logic end ####################    
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        trails = bank_payment_request.bank_payment_request_trails.with_action(BankPaymentRequestTrailAction.id_for(:take_control)).with_action_user(user.id)
        return true if trails.present?
      end
    end
    ############# Admin logic end ####################
  end

  def unapprove
    # When user role of creditor and reviewer
    if (user.vendor_payments_reviewer? || user.vendor_payments_creditor?)
      return associated_users.include?(user)
    end
  end

  def cancel_scheduled_payment
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      bank_payment_request.scheduled?
    end
    ############# Admin logic end ####################


    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      return bank_payment_request.scheduled?
    end
    ############# Reviewer logic end #########################

  end

  def retry_payment
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if bank_payment_request.credited? && (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
        return true
      end
    end
    ############# Admin logic end ####################

    if user.vendor_payments_creditor?
      if bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id
        if (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
          return true
        end
      end
    end


    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      if bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id
        return true if (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
      end
    end
    ############# Initiator logic end ####################
  end

  def approve_forward
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      bank_payment_request.approved?
    end
    ############# Admin logic end ####################


    ############# Creditor logic start ##################
    if user.vendor_payments_creditor?
      if reviewer.nil?
        admins = []
        user.company.users.only_vendor_payment_admins.each do |user|
          admins << {
              id: user.id,
              name: user.name
          }
        end
      else
        admins = []
      end
      return (reviewer.nil? && !admins.empty?)
    end
    ############# Creditor logic end ####################

  end

  def credit_in_credit_options
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id)
        return !bank_payment_request.credit_card?
      end
    end
  end

  def reviewer
    op = User::Team::Review::NextReviewer.(bank_payment_request)
    return op.user
  end

  def retrieve_balance(account, user)
    if account.blank? || user.blank?
      return 0
    end
    case account
      when :vendor_payment_wallet
        adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
        return adapter.balance
      when :company_credits
        adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
        return adapter.balance
    end
  end

  def associated_users
      BankTransfer::PaymentRequest::Review::AssociatedUsers.(user, bank_payment_request: bank_payment_request, user_before: bank_payment_request.controlling_user) rescue []
  end

end