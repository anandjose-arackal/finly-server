# operation that loads all the details about the payment request

class BankTransfer::PaymentRequest::Show < BankTransfer::PaymentRequest::Base

  def personalizer
    {
        init: {
            after: Personalizer::Process.new([:bank_transfer, :payment_requests, :show], :init, self)
        }
    }
  end

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end
  end

  def process

  end

  def post_process
    super()
    if params[:ref] == '1' and params[:n_id].present?
      Event::EBankPaymentRequest::Unset.(user, params)
    end

  end

  def success
    params[:payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::Show::RequestPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Show::RequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    require 'bank_transfer/payment_request/review/associated_users'

    attr_accessor :bank_payment_request, :payment_order, :actions, :bank_wallet_balance,
                  :manager, :finance_manager, :associated_users, :payments_verified, :payments_unverified,
                  :custom_field_config, :approvers, :invoice_categories, :invoice_line_items_categories,
                  :invoice_custom_fields, :invoice_line_items_custom_fields, :budgets

    def init
      self.bank_payment_request = params[:payment_request]
      self.payment_order = bank_payment_request.payment_order
      self.bank_wallet_balance = AccountManager::Balance::Check.(user.bank_wallet).balance rescue 0
      self.manager = User::Team::Approver.(bank_payment_request.owner, payment_request: bank_payment_request, type: :manager)
      self.finance_manager = User::Team::Approver.(bank_payment_request.owner, payment_request: bank_payment_request, type: :finance_manager)
      self.associated_users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.controlling_user) rescue []
      if bank_payment_request.credited?
        self.manager = associated_users.include?(manager) ? manager : nil
        self.finance_manager = associated_users.include?(finance_manager) ? finance_manager : nil
      end
      self.actions = retrieve_actions

      self.payments_unverified = []
      self.payments_verified = []
      # separating the verified and unverified payments
      self.payment_order.payments.each do |payment|
        if payment.receiving_user.is_a?(User) || payment.receiving_user.authorized
          self.payments_verified << payment
        else
          self.payments_unverified << payment
        end
      end
      self.custom_field_config = invoice_custom_field_configurations
      # op = BankTransfer::PaymentRequest::Approvers.(bank_payment_request: self.bank_payment_request)
      # if op.success?
      #   self.approvers = op.approvers
      # else
      #   self.approvers = []
      # end

      self.invoice_custom_fields = invoice_custom_field_configurations
      self.invoice_line_items_custom_fields = invoice_line_items_custom_field_configurations
      self.invoice_categories = self.user.company.categories.vendor_payments_only
      self.invoice_line_items_categories = self.user.company.categories.inward_invoice_items_only

      op = BudgetsCalculator::RelevantBudgets.(user, object: self.bank_payment_request)
      if op.success?
        self.budgets = op.budget_data
      end
    end

    def invoice_custom_field_configurations
      configurations = user.company.field_configurations.exclude_deleted
      configurations.with_parent_type(FieldParentType.id_for(:invoice))
    end

    def invoice_line_items_custom_field_configurations
      configurations = user.company.field_configurations.exclude_deleted
      configurations.with_parent_type(FieldParentType.id_for(:invoice_line_item))
    end

    def retrieve_actions
      actions = {}
      if admin_view? && user.vendor_payments_admin?
        actions = retrieve_admin_actions
      elsif (manager_view?) && bank_payment_request.processing?
        actions = retrieve_reviewer_actions
      elsif finance_view?
        actions = retrieve_creditor_actions
      elsif initiator_view?
        actions = retrieve_initiator_actions
      end
      actions
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

    ################## INITIATOR ACTIONS ########################
    def retrieve_initiator_actions
      actions = {}
      if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
        actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:summary_editable] = true
        actions[:payments_editable] = true
        actions[:attachments_editable] = true
        actions[:destroy] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
        balance = retrieve_balance(:vendor_payment_wallet, user)
        credit_enabled = false
        admin = false
        if (balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval) && !bank_payment_request.credit_card?
          credit_enabled = true
        elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
          credit_enabled = true
        end
        if user.vendor_payments_admin?
          admin = true
        end
        actions[:credit] = credit_enabled
        actions[:credit_options] = {}
        if credit_enabled && !bank_payment_request.credit_card?
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: credit_enabled,
                  messages: "You can directly credit this payment order from your Finly Money",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
        ############## Payment file start based on whether it's configured for this company ########
        if user.vendor_payments_admin?
          actions[:credit_options][:mark_as_credited] = {
              url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
              enabled: true,
              messages: "You can mark this payment order as credited",
              require_password: true,
              method: "patch"
          }
        end
        ##################### Payment File end ############################
      elsif bank_payment_request.processing? && bank_payment_request.owner_id == user.id
        actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
      elsif bank_payment_request.approved? && bank_payment_request.owner_id == user.id
        # actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        balance = retrieve_balance(:vendor_payment_wallet, user)
        credit_enabled = false
        admin = false
        if balance >= bank_payment_request.requested_amount_value
          credit_enabled = true
        elsif user.vendor_payments_admin? && !bank_payment_request.credit_card?
          credit_enabled = true
        end
        if user.vendor_payments_admin?
          admin = true
        end
        actions[:credit] = credit_enabled
        unless bank_payment_request.credit_card?
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: credit_enabled,
                  messages: "You can directly credit this payment order from your Finly Money",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
        # based on whether the configuration for payment file is enabled or not, add this block
        if user.vendor_payments_admin?
          actions[:credit_options][:mark_as_credited] = {
              url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
              enabled: true,
              messages: "You can mark this payment order as credited",
              require_password: true,
              method: "patch"
          }
        end
        #######################################################################################
      elsif self.bank_payment_request.credited? && self.bank_payment_request.payment_order.initiating_user_id == user.id
        # further check if the payment order has anu failed payments
        if self.bank_payment_request.payment_order.partially_completed? || self.bank_payment_request.payment_order.failed?
          actions[:retry] = {
              method: "patch",
              url: Rails.application.routes.url_helpers.bank_transfer_payment_retry_path(self.bank_payment_request)
          }
        end

        admin = user.vendor_payments_admin?
        # checking if this particular payment order is partially completed so that it can be credited later
        if self.bank_payment_request.payment_order.partially_completed?
          actions[:credit] = true
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money or Company Credits",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
      end
      actions
    end


    #################### REVIEWER ACTIONS ######################
    # def retrieve_reviewer_actions
    #   actions = {}
    #   if bank_payment_request.controlling_user_id == user.id
    #     actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
    #     actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
    #     actions[:summary_editable] = true
    #     actions[:payments_editable] = true
    #     actions[:attachments_editable] = true
    #     actions[:credit] = !bank_payment_request.credit_card?
    #     balance = retrieve_balance(:vendor_payment_wallet, user)
    #     enabled = false
    #     admin = false
    #     if balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval
    #       enabled = true
    #     else
    #       # i.e if the user is an admin, even from the reviewer view, they should be able to
    #       # credit the payment request from company credits
    #       if user.vendor_payments_admin?
    #         balance = retrieve_balance(:company_credits, user)
    #         if balance >= bank_payment_request.requested_amount_value
    #           enabled = true
    #         end
    #       end
    #     end
    #     if user.vendor_payments_admin?
    #       admin = true
    #     end
    #     actions[:credit_options] = {}
    #     if enabled
    #       actions[:credit_options] = {
    #           credit: {
    #               url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
    #               enabled: enabled,
    #               messages: "You can directly credit this payment order from your Finly Money",
    #               require_password: true,
    #               initiating_account: admin,
    #               method: "patch"
    #           }
    #       }
    #     end
    #     # based on whether the configuration for payment file is enabled or not, add this block
    #     actions[:credit_options][:mark_as_credited] = {
    #         url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
    #         enabled: true,
    #         messages: "You can mark this payment order as credited",
    #         require_password: true,
    #         method: "patch"
    #     }
    #     #######################################################################################
    #     op = User::Team::Review::NextReviewer.(bank_payment_request)
    #     reviewer = op.user
    #     if reviewer.nil?
    #       button_type = "dropdown"
    #       message = "You can forward this request to another admin for them to credit it"
    #       admins = []
    #       user.company.users.only_vendor_payment_admins.each do |user|
    #         admins << {
    #             id: user.id,
    #             name: user.name
    #         }
    #       end
    #     else
    #       button_type = "button"
    #       message = "The payment request will move to #{reviewer.name} for approval"
    #       admins = []
    #       actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
    #     end
    #     if reviewer.nil? && !admins.empty?
    #       actions[:credit_options][:approve_forward] = {
    #           url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
    #           messages: message,
    #           enabled: true,
    #           require_password: true,
    #           button_type: button_type,
    #           users: admins,
    #           method: "patch",
    #           type: 7
    #       }
    #     end
    #   elsif associated_users&.include?(user)
    #     actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
    #   elsif bank_payment_request.scheduled?
    #     # if the payment request is scheduled, give the option to cancel it here
    #     actions[:cancel] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_payment_order_path(bank_payment_request.payment_order)}
    #   end
    #   actions
    # end

    def retrieve_reviewer_actions
      actions = {}
      if bank_payment_request.get_reviewers.include? user
        actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:summary_editable] = true
        actions[:payments_editable] = true
        actions[:attachments_editable] = true
        actions[:credit] = !bank_payment_request.credit_card?
        balance = retrieve_balance(:vendor_payment_wallet, user)
        enabled = false
        admin = false
        if balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval
          enabled = true
        else
          # i.e if the user is an admin, even from the reviewer view, they should be able to
          # credit the payment request from company credits
          if user.vendor_payments_admin?
            balance = retrieve_balance(:company_credits, user)
            if balance >= bank_payment_request.requested_amount_value
              enabled = true
            end
          end
        end
        if user.vendor_payments_admin?
          admin = true
        end
        actions[:credit_options] = {}
        if enabled
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: enabled,
                  messages: "You can directly credit this payment order from your Finly Money",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
        # based on whether the configuration for payment file is enabled or not, add this block
        actions[:credit_options][:mark_as_credited] = {
            url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
            enabled: true,
            messages: "You can mark this payment order as credited",
            require_password: true,
            method: "patch"
        }
        #######################################################################################
        # op = User::Team::Review::NextReviewer.(bank_payment_request)
        # reviewer = op.user
        # if reviewer.nil?
        #   button_type = "dropdown"
        #   message = "You can forward this request to another admin for them to credit it"
        #   admins = []
        #   user.company.users.only_vendor_payment_admins.each do |user|
        #     admins << {
        #         id: user.id,
        #         name: user.name
        #     }
        #   end
        # else
        #   button_type = "button"
        #   message = "The payment request will move to #{reviewer.name} for approval"
        #   admins = []
        #   actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        # end
        # if reviewer.nil? && !admins.empty?
        #   actions[:credit_options][:approve_forward] = {
        #       url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
        #       messages: message,
        #       enabled: true,
        #       require_password: true,
        #       button_type: button_type,
        #       users: admins,
        #       method: "patch",
        #       type: 7
        #   }
        # end
      # elsif associated_users&.include?(user)
      elsif bank_payment_request.get_reviewers.present?
        actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
      elsif bank_payment_request.scheduled?
        # if the payment request is scheduled, give the option to cancel it here
        actions[:cancel] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_payment_order_path(bank_payment_request.payment_order)}
      end
      actions
    end

    ################### CREDITOR ACTIONS #######################
    def retrieve_creditor_actions
      actions = {}
      # if bank_payment_request.controlling_user_id == user.id && bank_payment_request.processing?
      if bank_payment_request.document_role_users(:creditor).include? user && bank_payment_request.approved? # todo check logic
        # actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:summary_editable] = true
        actions[:payments_editable] = true
        actions[:attachments_editable] = true
        # actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:credit] = !bank_payment_request.credit_card?
        balance = retrieve_balance(:vendor_payment_wallet, user)
        enabled = false
        admin = false
        if balance >= bank_payment_request.requested_amount_value && !bank_payment_request.require_approval
          enabled = true
        else
          # i.e if the user is an admin, even from the creditor view, they should be able to
          # credit the payment request from company credits
          if user.vendor_payments_admin?
            balance = retrieve_balance(:company_credits, user)
            if balance >= bank_payment_request.requested_amount_value
              enabled = true
            end
          end
        end
        if user.vendor_payments_admin?
          admin = true
        end
        actions[:credit_options] = {}
        if enabled && !bank_payment_request.credit_card?
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: enabled,
                  messages: "You can directly credit this payment order from your Finly Money",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
        # based on whether the configuration for payment file is enabled or not, add this block
        actions[:credit_options][:mark_as_credited] = {
            url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
            enabled: true,
            messages: "You can mark this payment order as credited",
            require_password: true,
            method: "patch"
        }
        #######################################################################################
        # op = User::Team::Review::NextReviewer.(bank_payment_request)
        # reviewer = op.user
        # if reviewer.nil?
        #   button_type = "dropdown"
        #   admins = []
        #   user.company.users.only_vendor_payment_admins.each do |user|
        #     admins << {
        #         id: user.id,
        #         name: user.name
        #     }
        #   end
        # else
        #   button_type = "button"
        #   admins = []
        # end
        # if reviewer.nil? && !admins.empty?
        #   actions[:credit_options][:approve_forward] = {
        #       url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
        #       messages: "",
        #       enabled: true,
        #       require_password: true,
        #       button_type: button_type,
        #       users: admins,
        #       method: "patch",
        #       type: 7
        #   }
        # end
      # elsif associated_users.include?(user)
      #   actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
      elsif self.bank_payment_request.credited? && self.bank_payment_request.payment_order.initiating_user_id == user.id
        # further check if the payment order has anu failed payments
        if self.bank_payment_request.payment_order.partially_completed? || self.bank_payment_request.payment_order.failed?
          actions[:retry] = {
              method: "patch",
              url: Rails.application.routes.url_helpers.bank_transfer_payment_retry_path(self.bank_payment_request)
          }
        end

        admin = user.vendor_payments_admin?
        # checking if this particular payment order is partially completed so that it can be credited later
        if self.bank_payment_request.payment_order.partially_completed?
          actions[:credit] = true
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money",
                  require_password: true,
                  initiating_account: admin,
                  method: "patch"
              }
          }
        end
      end
      actions
    end

    def retrieve_admin_actions
      actions = {}
      if bank_payment_request.processing? && bank_payment_request.get_reviewers.include?(user)
        actions[:summary_editable] = true
        actions[:payments_editable] = true
        actions[:attachments_editable] = true
        actions[:credit] = !bank_payment_request.credit_card?
        balance = retrieve_balance(:vendor_payment_wallet, user)
        admins = []
        user.company.users.only_vendor_payment_admins.each do |admin|
          admins << {
              id: admin.id,
              name: admin.name
          }
        end
        actions[:credit_options] = {}
        unless bank_payment_request.credit_card?
          actions[:credit_options][:credit] = {
              url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
              enabled: true,
              messages: "You can directly credit this payment order from your Finly Money or Company Credits",
              require_password: true,
              initiating_account: true,
              method: "patch"
          }
        end
        # based on whether the configuration for payment file is enabled or not, add this block
        actions[:credit_options][:mark_as_credited] = {
            url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
            enabled: true,
            messages: "You can mark this payment order as credited",
            require_password: true,
            method: "patch"
        }
        #######################################################################################
        # unless admins.empty?
        #   actions[:credit_options][:approve_forward] = {
        #       url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
        #       messages: "You can forward this payment request to another admin to credit it",
        #       enabled: true,
        #       require_password: true,
        #       button_type: "dropdown",
        #       users: admins,
        #       method: "patch",
        #       type: 7
        #   }
        # end

        # adding approve and reject options for admin who has taken control
        actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}

        # for the return control action, first we gotta check if this particular payment order has
        # been taken control of by the admin and then show the action
        # trails = bank_payment_request.trails.with_action_id(BankPaymentRequestTrailAction.id_for(:take_control)).with_action_user(user.id)
        # if trails.present?
        #   actions[:return_control] = {method: "patch", type: 8, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        # end
        if bank_payment_request.action_users(:return_control).include? user
          actions[:return_control] = {method: "patch", type: 8, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        end
      elsif bank_payment_request.processing?
        actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
      elsif bank_payment_request.open? && bank_payment_request.owner_id == user.id
        actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:destroy] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
      elsif bank_payment_request.scheduled?
        # if the payment request is scheduled, give the option to cancel it here
        actions[:cancel] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_payment_order_path(bank_payment_request.payment_order)}
      elsif bank_payment_request.approved?
        actions[:credit] = true
        balance = retrieve_balance(:vendor_payment_wallet, user)
        admins = []
        user.company.users.only_vendor_payment_admins.each do |admin|
          admins << {
              id: admin.id,
              name: admin.name
          }
        end
        unless bank_payment_request.credit_card?
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money or Company Credits",
                  require_password: true,
                  initiating_account: true,
                  method: "patch"
              }
          }
        end
        actions[:credit_options] = {} unless actions[:credit_options].present?
        # actions[:credit_options][:approve_forward] = {
        #     url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
        #     messages: "You can forward this payment request to another admin to credit it",
        #     enabled: true,
        #     require_password: true,
        #     button_type: "dropdown",
        #     users: admins,
        #     method: "patch",
        #     type: 7
        # }
        # based on whether the configuration for payment file is enabled or not, add this block
        actions[:credit_options][:mark_as_credited] = {
            url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_mark_as_credited_path(bank_payment_request),
            enabled: true,
            messages: "You can mark this payment order as credited",
            require_password: true,
            method: "patch"
        }
        #######################################################################################
      elsif bank_payment_request.credited?
        # further check if the payment order has anu failed payments
        if self.bank_payment_request.payment_order.partially_completed? || self.bank_payment_request.payment_order.failed?
          actions[:retry] = {
              method: "patch",
              url: Rails.application.routes.url_helpers.bank_transfer_payment_retry_path(self.bank_payment_request)
          }
        end

        # check if the payment order is partially completed, so that they can retry the remaining payments
        if self.bank_payment_request.payment_order.partially_completed?
          actions[:credit] = true
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money or Company Credits",
                  require_password: true,
                  initiating_account: true,
                  method: "patch"
              }
          }
        end
      end
      actions
    end
  end
end