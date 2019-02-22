class ActionsManager::Master::BankTransfer::PaymentRequest::Show < ActionsManager::Master::Base

  register_handle :payment_ticket_show
  register_actions [ :mark_as_credited, :delete, :submit, :credit, :credit_options, :add_payments, :edit_order_summary, :download_payments_file, :payments_history, :edit_payment_history, :delete_payment_history, :attachments_editable, :reject, :retract, :approve, :take_control, :return_control, :unapprove, :cancel_scheduled_payment, :retry_payment, :credit_in_credit_options, :policy_editable ]

  def initialize(user=nil, params={})
    super
    result = BankTransfer::PaymentRequest::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.bank_payment_request = result.bank_payment_request
  end

  def mark_as_credited
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      return true
      # if (bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user))
      #   return true
      # elsif bank_payment_request.approved?
      #   return true
      # end
    end
    ############# Admin logic end ####################    

    ############# Reviewer logic start ####################
    # if user.vendor_payments_reviewer?
    #   if (!bank_payment_request.approved? && !bank_payment_request.auto_approved?)
    #     if (bank_payment_request.get_reviewers.include?(user))
    #       return true
    #     end
    #   end
    # end
    ############# Reviewer logic start ####################

    ############# Creditor logic start ####################
    if user.vendor_payments_creditor?
      if bank_payment_request.document_role_users(:creditor).include?(user)
        return true
      end
    end
    ############# Creditor logic end ######################


    ############# Initiator logic start ####################
    # if user.vendor_payments_initiator?
    #   if (bank_payment_request.open? || bank_payment_request.rejected?) && (bank_payment_request.owner_id == user.id)
    #     return user.vendor_payments_admin? ? true : false
    #   elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
    #     return user.vendor_payments_admin?
    #   end
    # end
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
    # if user.vendor_payments_admin?
    #   if ( (bank_payment_request.approved? || bank_payment_request.auto_approved?)  )
    #     return true
    #   # elsif bank_payment_request.approved?
    #   #     return true
    #   elsif bank_payment_request.credited?
    #     return bank_payment_request.payment_order.partially_completed?
    #   end
    # end

    if user.vendor_payments_admin?
      if !bank_payment_request.credited?
        return true
      end
    end
    ############# Admin logic end #########################

    ############# Reviewer logic start #########################
    # if bank_payment_request.processing?
    #   if (bank_payment_request.get_reviewers.include?(user))
    #     return !bank_payment_request.credit_card?
    #   end
    # end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor? && !bank_payment_request.open?
      if bank_payment_request.document_role_users(:creditor).include?(user)
        return !bank_payment_request.credit_card?
      elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
        return bank_payment_request.payment_order.partially_completed?
      end
    end
    ############# Creditor logic end #########################


    ########## Initiator logic start ######################### 
    # if user.vendor_payments_initiator?
    #   if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
    #     balance = retrieve_balance(:vendor_payment_wallet, user)
    #     if (balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval) && !bank_payment_request.credit_card?
    #       return true
    #     elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
    #       return true
    #     end
    #   elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
    #     balance = retrieve_balance(:vendor_payment_wallet, user)
    #     if balance >= bank_payment_request.requested_amount_value
    #       return true
    #     elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
    #       return true
    #     end
    #   elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
    #     if bank_payment_request.payment_order.partially_completed?
    #       return true
    #     end          
    #   end
    # end
    ########### Initiator logic end ##############################
  end

  def credit_options
    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if !bank_payment_request.credited?
        return true
      end
    end
    ############# Admin logic end #######################

    ############# Reviewer logic start #########################
    # if bank_payment_request.processing?
    #   if (bank_payment_request.get_reviewers.include?(user))
    #     balance = retrieve_balance(:vendor_payment_wallet, user)
    #     if (balance >= bank_payment_request.requested_amount_value) && !bank_payment_request.require_approval
    #       return true
    #     else
    #       if user.vendor_payments_admin?
    #         balance = retrieve_balance(:company_credits, user)
    #         return true if (balance >= bank_payment_request.requested_amount_value)
    #       end
    #     end
    #   end
    # end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor? && !bank_payment_request.open?

      #Policy User Role is not generalized
      policy_user_role = user.policy_user_roles.where(user_role_id: UserRole.id_for(:creditor), policy_id: bank_payment_request.policy_id).last rescue nil
      allow_credit = true
     if !policy_user_role.blank?
        min_amount = policy_user_role.min_amount
        max_amount = policy_user_role.max_amount
        if min_amount.present?
          allow_credit = (bank_payment_request.requested_amount_value >= min_amount)
        end
        if max_amount.present? && allow_credit
          allow_credit = (max_amount > 0) && (bank_payment_request.requested_amount_value <= max_amount)
        end
      end
      if allow_credit
        if bank_payment_request.document_role_users(:creditor).include?(user)
          # check if amount lies within threshold limit of creditor
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
    end
    ############# Creditor logic end ###########################

    ############# Initiator logic start ####################
    # if user.vendor_payments_initiator?
    #   if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
    #     return (credit && !bank_payment_request.credit_card?)
    #   elsif (bank_payment_request.approved? && bank_payment_request.owner_id == user.id)
    #     return !bank_payment_request.credit_card?    
    #   elsif (bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id)
    #     if bank_payment_request.payment_order.partially_completed?
    #       return true
    #     end
    #   end
    # end
    ############# Initiator logic end ####################
  end

  def add_payments
  end

  def edit_order_summary
    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
        return true
      end
    end
    ############# Initiator logic end ####################

    ############# Reviewer logic start ###################
    if user.vendor_payments_reviewer?
      # When control comes to the user where user is allowed to approve, he can edit the bank payment request too before approval
      return true if bank_payment_request.action_users(:approve).include?(user)
    end
    ############# Reviewer logic end ####################


    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      return true if bank_payment_request.action_users(:return_control).include?(user)
    end
    ############# Admin logic end ####################
  end

  def download_payments_file
    true if bank_payment_request.approved?
  end

  def payments_history
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      return true
    end
    ############# Admin logic end ####################

    ############# Reviewer logic start ####################
    if user.vendor_payments_reviewer?
      return true if (bank_payment_request.action_users(:approve).include?(user) && bank_payment_request.processing? || bank_payment_request.credited?)
      ############# Reviewer logic end ####################

      ############# Initiator logic start ####################
    elsif (bank_payment_request.owner_id == user.id)
      if (bank_payment_request.processing? || bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.credited?)
        return true
      end
    end
    ############# Initiator logic end ####################
  end

  def edit_payment_history
    ############# Reviewer logic start ####################
    if user.vendor_payments_reviewer?
      return true if (bank_payment_request.action_users(:approve).include?(user) && bank_payment_request.processing?)
      ############# Reviewer logic end ####################

      ############# Initiator logic start ####################
    elsif (bank_payment_request.owner_id == user.id)
      if (bank_payment_request.retracted? || bank_payment_request.open? || bank_payment_request.rejected?)
        return true
      end
    end
    ############# Initiator logic end ####################
  end

  def delete_payment_history
    ############# Reviewer logic start ####################
    if user.vendor_payments_reviewer?
      return true if (bank_payment_request.action_users(:approve).include?(user) && bank_payment_request.processing?)
      ############# Reviewer logic end ####################

      ############# Initiator logic start ####################
    elsif (bank_payment_request.owner_id == user.id)
      if (bank_payment_request.retracted? || bank_payment_request.open? || bank_payment_request.rejected?)
        return true
      end
    end
    ############# Initiator logic end ####################
  end

  def attachments_editable

    ############# Admin logic start #######################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user))

      end
    end
    ############# Admin logic end #########################


    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.get_reviewers.include?(user))
        return true
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    if user.vendor_payments_creditor?
      if bank_payment_request.document_role_users(:creditor).include?(user) && bank_payment_request.approved?
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
      if (bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user))
        return true
      end
    end
    ############# Admin logic end #########################

    ############# Reviewer logic start #########################
    if bank_payment_request.processing?
      if (bank_payment_request.get_reviewers.include?(user))
        return true
      end
    end
    ############# Reviewer logic end #########################

    # ############# Creditor logic start #########################
    # if user.vendor_payments_creditor?
    #   if bank_payment_request.document_role_users(:creditor).include?(user) && bank_payment_request.approved?
    #     return true
    #   end
    # end
    # ############# Creditor logic end #########################
  end

  def retract
    ############# Initiator logic start ####################
    if user.vendor_payments_initiator?
      if (bank_payment_request.processing? && bank_payment_request.owner_id == user.id)
        return true
      # elsif bank_payment_request.approved? && bank_payment_request.owner_id == user.id
      #   return true
      end
    end
    ############# Initiator logic end ####################
  end

  def approve
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if (bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user))
        return true
      end
    end 
    ############# Admin logic end ####################


    ############# Reviewer logic start #########################
    if user.vendor_payments_reviewer?
      if bank_payment_request.processing?
        if (bank_payment_request.get_reviewers.include?(user))
          return true
        end
      end
    end
    ############# Reviewer logic end #########################

    ############# Creditor logic start #########################
    # if user.vendor_payments_creditor?
    #   if bank_payment_request.document_role_users(:creditor).include?(user) && bank_payment_request.processing?
    #     return true
    #   end
    # end
    ############# Creditor logic end #########################

  end

  def take_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      return true if (bank_payment_request.processing? && bank_payment_request.get_reviewers.exclude?(user))
    end
    ############# Admin logic end ####################    
  end

  def return_control
    ############# Admin logic start ####################
    if user.vendor_payments_admin?
      if bank_payment_request.processing?
        return true if bank_payment_request.action_users(:return_control).include?(user)
      end
    end
    ############# Admin logic end ####################
  end

  def unapprove
    if bank_payment_request.action_users(:unapprove).include?(user)
      last_trail = bank_payment_request.trails.last rescue nil
      if (last_trail.action_id == TrailAction.id_for(:unapprove)) &&
          (last_trail.action_user_id == user.id)
        return true
      end
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
      if (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
        return true
      end
    end
    ############# Admin logic end ####################

    ############# Creditor logic start ####################
    if user.vendor_payments_creditor?
      if bank_payment_request.document_role_users(:creditor).include?(user)
        if (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
          return true
        end
      end
    end

    ############# Creditor logic end ####################


    ############# Initiator logic start ####################
    # if user.vendor_payments_initiator?
    #   if bank_payment_request.credited? && bank_payment_request.payment_order.initiating_user_id == user.id
    #     return true if (bank_payment_request.payment_order.partially_completed? || bank_payment_request.payment_order.failed?)
    #   end
    # end
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
      if (bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user))
        return !bank_payment_request.credit_card?
      end
    end
  end

  def policy_editable
    if (bank_payment_request.owner_id == user.id)
      bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?
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