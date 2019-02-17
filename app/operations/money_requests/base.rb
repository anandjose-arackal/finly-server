class MoneyRequests::Base < BaseOperation
  attr_accessor :money_request, :workflow_output

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    if params[:filter_search].present?
      params[:filter_search].strip! if params[:filter_search].is_a?(String)
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = MoneyRequests::Index.(user, params).money_requests.with_id(id).first rescue nil
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
  end

  def success
    params[:money_request] = self.money_request
    MoneyRequests::Base::Presenter.new(user, params, messages)
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

  class MoneyRequests::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request, :items, :manager, :status, :total, #:money_request_currency,
                  :required_by_date, :comments, :actions, :policies, :selected_policy, :violations,
                  :result, :card, :cash_pockets, :reviewal_chains, :awaiting_credit, :finance_managers

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
      # self.manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :manager)
      # self.finance_manager = User::Team::Approver.(money_request.user, money_request: self.money_request, type: :finance_manager)
      
      self.finance_managers = self.money_request.document_role_users(:finance_managers)

      if MoneyRequest.status_ids(:approved, :auto_approved).include?(money_request.status_id)
        self.awaiting_credit = true
      else
        self.awaiting_credit = false
      end
      self.card = load_card
      self.cash_pockets = money_request.user.user_pockets.cash_pockets_only

      self.reviewal_chains = []
      params[:reviewal_document] = money_request

      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }
        self.reviewal_chains.push(chain)
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      if op.success?
        return op.chain
      else
        return nil
      end
    end

    def retrieve_policies
      if money_request.user.enforce_policy_enabled?
        return money_request.user.policies.with_application(current_app).non_default
      end
      money_request.user.policies.with_application(current_app)
    end

    def load_card
      assigned = money_request.user.cards.expense_cards.present?
      {assigned: assigned}
    end

    def load_actions
      # actions = {meta: {base_url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])},
      #            credit_actions: {
      #                initiating_accounts: [],
      #                receiving_accounts: []}}
      #
      # # Load base actions
      # if admin_view? or finance_view? or manager_view?
      #   actions[:credit] = true
      #   actions[:debit] = true
      #   if admin_view? and self.money_request.can_take_control? and not self.money_request.controlling_user?(user)
      #     actions[:take_control] = true
      #   elsif self.money_request.processing? and self.money_request.controlling_user?(user)
      #     actions[:editable] = true
      #     if self.money_request.payment_mode_card?
      #       actions[:approve_and_credit] = true
      #       actions[:approve_and_forward_to] = true
      #     else
      #       actions[:approve] = true
      #     end
      #     actions[:reject] = true
      #   elsif (manager_view? or finance_view?) and self.money_request.can_unapprove? and MoneyRequests::AssociatedUsers.(self.user, money_request: self.money_request, user_before: self.money_request.controlling_user).include?(user)
      #     actions[:unapprove] = true
      #   end
      # else
      #   # Personal View
      #   if self.money_request.open? or self.money_request.retracted? or self.money_request.rejected?
      #     actions[:delete] = true
      #     actions[:editable] = true
      #     actions[:submit] = true
      #   elsif self.money_request.can_retract?
      #     actions[:retract] = true
      #   end
      # end
      #
      # # Load credit actions
      # if actions[:approve_and_credit]
      #
      #   from_user_transferable_cards =  user.cards.with_non_personal_fund_transfer
      #   to_user_creditable_cards = money_request.user.cards.creditable_cards
      #   from_user_name = 'Your'
      #   personal_transfer = self.user == self.money_request.user
      #   to_user_name = personal_transfer ? 'Your' : "#{self.money_request.user.name}'s"
      #   initiating_actions = actions[:credit_actions][:initiating_accounts]
      #   receiving_actions = actions[:credit_actions][:receiving_accounts]
      #
      #   balances = User::Balance.(user, target_user: money_request.user, target_user_card: true,
      #       target_user_wallet: true, current_user_card: true, current_user_wallet: true,
      #       virtual_account: true, view: params[:view]).balances
      #
      #   # From Actions
      #   # Virtual Account
      #   if user.company_admin?
      #     balance = balances[:virtual_account][:balance] rescue nil
      #     initiating_actions << {type: :virtual_account, id: user.company.id, name: 'Company Credits',
      #                            balance: balance, active: true}
      #   end
      #
      #   # Wallet
      #   balance = balances[:current_user][:wallet][:balance] rescue nil
      #   initiating_actions << {type: :wallet, id: user.wallet.id, name: "#{from_user_name} Finly Money",
      #                          balance: balance, active: true}
      #
      #   # Cards
      #   if from_user_transferable_cards.present?
      #     from_user_transferable_cards.each do |card|
      #       balance = balances[:current_user][:card][card.id][:balance] rescue nil
      #       eligibility = balances[:current_user][:card][card.id][:eligibility] rescue nil
      #       initiating_actions << {type: :card, id: card.id, name: "#{from_user_name} #{card.card_program.name} Card",
      #                              balance: balance, eligibility: eligibility, active: card.active}
      #     end
      #   end
      #
      #   # To Actions
      #   # Wallet
      #   balance = balances[:target_user][:wallet][:balance] rescue nil
      #   receiving_actions << {type: :wallet, id: money_request.user.wallet.id, name: "#{to_user_name} Finly Money", balance: balance, active: true}
      #
      #   # Cards
      #   if to_user_creditable_cards.present?
      #     to_user_creditable_cards.each do |card|
      #       balance = balances[:target_user][:card][card.id][:balance] rescue nil
      #       eligibility = balances[:target_user][:card][card.id][:eligibility] rescue nil
      #       receiving_actions << {type: :card, id: card.id, name: "#{to_user_name} #{card.card_program.name} Card",
      #                             balance: balance, eligibility: eligibility, active: card.active}
      #     end
      #   end
      # end
      # NEW CODE

      actions = {meta: {base_url: Rails.application.routes.url_helpers.money_request_path(id: money_request.id, view: params[:view])},
                 credit_actions: {
                     initiating_accounts: [],
                     receiving_accounts: []}}

      # Load base actions
      if admin_view? or finance_view? or manager_view?
        actions[:credit] = true
        actions[:debit] = true
        if admin_view?
          if self.money_request.can_take_control? and not self.money_request.get_reviewers.include?(user)
            actions[:take_control] = true
          elsif self.money_request.processing? and self.money_request.get_reviewers.include?(user)
            actions[:editable] = true
            if self.money_request.payment_mode_card?
              actions[:approve_and_credit] = true
              actions[:approve_and_forward_to] = true
            else
              actions[:approve] = true
            end
            actions[:reject] = true
          end
        elsif manager_view?
          if self.money_request.processing? && self.money_request.get_reviewers.include?(user)
            actions[:editable] = true
            if self.money_request.payment_mode_card?
              actions[:approve_and_credit] = true
              # actions[:approve_and_forward_to] = true
            else
              actions[:approve] = true
            end
            actions[:reject] = true
          end
          if self.money_request.can_unapprove? && money_request.action_users(:unapprove).include?(user)
            actions[:unapprove] = true
          end
        end
      else
        # Personal View
        if self.money_request.open? or self.money_request.retracted? or self.money_request.rejected?
          actions[:delete] = true
          actions[:editable] = true
          actions[:submit] = true
        elsif self.money_request.can_retract?
          actions[:retract] = true
        end
      end

      # Load credit actions
      if actions[:approve_and_credit]

        from_user_transferable_cards =  user.cards.with_non_personal_fund_transfer
        to_user_creditable_cards = money_request.user.cards.creditable_cards
        from_user_name = 'Your'
        personal_transfer = self.user == self.money_request.user
        to_user_name = personal_transfer ? 'Your' : "#{self.money_request.user.name}'s"
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
            initiating_actions << {type: :card, id: card.id, name: "#{from_user_name} #{card.card_program.name} Card",
                                   balance: balance, eligibility: eligibility, active: card.active}
          end
        end

        # To Actions
        # Wallet
        balance = balances[:target_user][:wallet][:balance] rescue nil
        receiving_actions << {type: :wallet, id: money_request.user.wallet.id, name: "#{to_user_name} Finly Money", balance: balance, active: true}

        # Cards
        if to_user_creditable_cards.present?
          to_user_creditable_cards.each do |card|
            balance = balances[:target_user][:card][card.id][:balance] rescue nil
            eligibility = balances[:target_user][:card][card.id][:eligibility] rescue nil
            receiving_actions << {type: :card, id: card.id, name: "#{to_user_name} #{card.card_program.name} Card",
                                  balance: balance, eligibility: eligibility, active: card.active}
          end
        end
      end
      actions
    end

    def forwardable_users
      if self.actions.present? and self.actions[:approve_and_forward_to].present?
        new_users = []
        next_reviewer_presenter = User::Team::Review::NextReviewer.(self.money_request)
        next_reviewer = next_reviewer_presenter.user
        if next_reviewer.present?
          new_users << {
              approver: next_reviewer,
              role_id: next_reviewer_presenter.role_id
          }
        end

        # adding all the admins of the company
        admins = user.company.users.only_admins
        admins.each do |admin|
          present = false
          new_users.each do |new_user|
            if new_user[:approver].id == admin.id
              present = true
            end
          end
          unless present
            new_users << {
                approver: admin,
                role_id: UserRole.id_for(:admin)
            }
          end
        end
        return new_users
        #
        # users = User::Team::Review::PendingApprovers.(user, money_request: self.money_request).approvers rescue nil
        # return nil if users.blank?
        # new_users = []
        # users.each do |item|
        #   unless item[:approver].id == user.id
        #     new_users << item
        #   end
        # end
        # return new_users
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
