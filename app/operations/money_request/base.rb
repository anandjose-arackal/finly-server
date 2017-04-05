class MoneyRequest::Base < BaseOperation
  attr_accessor :money_request

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = MoneyRequest::Index.(user, params).money_requests.with_id(id).first rescue nil
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
  end

  def success
    params[:money_request] = self.money_request
    MoneyRequest::Base::Presenter.new(user, params, messages)
  end

  def user_role_for_money_request
    if user.id == money_request.user.id
      UserRole.employee_id
    elsif user.manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :manager})
      UserRole.manager_id
    elsif user.finance_manager? and User::Team::IsApprover.(user, {money_request: self.money_request, type: :finance_manager})
      UserRole.finance_manager_id
    end
  end

  class MoneyRequest::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request, :items, :manager, :finance_manager, :status, :total, #:money_request_currency,
                  :required_by_date, :comments, :actions, :policies, :selected_policy, :violations,
                  :result, :card

    def init
      self.money_request = params[:money_request]
      self.items = money_request.items
      self.status = money_request.relative_status_name user
      self.total = money_request.total_amount
      self.required_by_date = money_request.required_by_date
      self.comments = money_request.comments
      self.actions = load_actions
      self.policies = retrieve_policies
      self.selected_policy = money_request.policy
      self.manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :manager)
      self.finance_manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :finance_manager)
      self.card = load_card
    end

    def retrieve_policies
      policies = []
      unless money_request.user.enforce_policy_enabled?
        policies << {id: 0, name: 'None'}
      end
      policies + money_request.user.policies.non_default
    end

    def load_card
      assigned = money_request.user.cards.expense_cards.present?
      {assigned: assigned}
    end

    def load_actions
      actions = {meta: {base_url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])},
                 credit_actions: {
                     initiating_accounts: [],
                     receiving_accounts: []}}

      # Load base actions
      if admin_view? or finance_view? or manager_view?
        actions[:credit] = true
        actions[:debit] = true
        if admin_view? and self.money_request.can_take_control? and not self.money_request.controlling_user?(user)
          actions[:take_control] = true
        elsif self.money_request.processing? and self.money_request.controlling_user?(user)
          if self.money_request.payment_mode_card?
            actions[:approve_and_credit] = true
            actions[:approve_and_forward_to] = true
          else
            actions[:approve] = true
          end
          actions[:reject] = true
        elsif (manager_view? or finance_view?) and self.money_request.can_unapprove? and MoneyRequest::AssociatedUsers.(self.user, money_request: self.money_request, user_before: self.money_request.controlling_user).include?(user)
          actions[:unapprove] = true
        end
      else
        # Personal View
        if self.money_request.open? or self.money_request.retracted? or self.money_request.rejected?
          actions[:delete] = true
          actions[:editable] = true
          actions[:submit] = true
        elsif self.money_request.processing?
          actions[:retract] = {url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])}
        end
      end

      # Load credit actions
      if actions[:approve_and_credit]

        from_user_transferable_cards =  user.cards.with_non_personal_fund_transfer
        to_user_creditable_cards = money_request.user.cards.creditable_cards
        from_user_name = 'Your'
        personal_transfer = self.user == self.money_request.user
        to_user_name = personal_transfer ? 'Your' : self.money_request.user.name
        initiating_actions = actions[:credit_actions][:initiating_accounts]
        receiving_actions = actions[:credit_actions][:receiving_accounts]

        balances = User::Balance.(user, target_user: money_request.user, target_user_card: true,
            target_user_wallet: true, current_user_card: true, current_user_wallet: true,
            virtual_account: true, view: params[:view]).balances

        # From Actions
        # Virtual Account
        if user.company_admin?
          balance = balances[:virtual_account][:balance] rescue nil
          initiating_actions << {type: :virtual_account, id: user.company.id, name: 'Company Credits',
                                 balance: balance, active: true}
        end

        # Wallet
        balance = balances[:current_user][:wallet][:balance] rescue nil
        initiating_actions << {type: :wallet, id: user.wallet.id, name: "#{from_user_name} Finly Money",
                               balance: balance, active: true}

        # Cards
        if from_user_transferable_cards.present?
          from_user_transferable_cards.each do |card|
            balance = balances[:current_user][:card][card.id][:balance] rescue nil
            eligibility = balances[:current_user][:card][card.id][:eligibility] rescue nil
            initiating_actions << {type: :card, id: card.id, name: "#{from_user_name}'s #{card.card_program.name} Card",
                                   balance: balance, eligibility: eligibility, active: card.active}
          end
        end

        # To Actions
        # Wallet
        balance = balances[:target_user][:wallet][:balance] rescue nil
        receiving_actions << {type: :wallet, id: money_request.user.wallet.id, name: "#{to_user_name}'s Finly Money", balance: balance, active: true}

        # Cards
        if to_user_creditable_cards.present?
          to_user_creditable_cards.each do |card|
            balance = balances[:target_user][:card][card.id][:balance] rescue nil
            eligibility = balances[:target_user][:card][card.id][:eligibility] rescue nil
            receiving_actions << {type: :card, id: card.id, name: "#{to_user_name}'s #{card.card_program.name} Card",
                                  balance: balance, eligibility: eligibility, active: card.active}
          end
        end
      end
      actions
    end

    def forwardable_users
      if self.actions.present? and self.actions[:approve_and_forward_to].present?
        users = User::Team::Review::PendingApprovers.(user, money_request: self.money_request).approvers rescue nil
        return nil if users.blank?
        new_users = []
        users.each do |item|
          unless item[:approver].id == user.id
            new_users << item
          end
        end
        return new_users
      end
      nil
    end

    def status_name(money_request)
      return nil if money_request.blank?
      if money_request.processing? and money_request.controlling_user?(self.user)
        'Awaiting Approval'
      else
        money_request.status_name
      end
    end

  end

end
