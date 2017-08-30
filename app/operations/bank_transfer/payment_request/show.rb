# operation that loads all the details about the payment request

class BankTransfer::PaymentRequest::Show < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
    # self.bank_payment_request = BankPaymentRequest.find_by(id: id)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end
  end

  def process

  end

  def success
    params[:payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::Show::RequestPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Show::RequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    require 'bank_transfer/payment_request/review/associated_users'

    attr_accessor :bank_payment_request, :payment_order, :actions, :bank_wallet_balance,
                  :manager, :finance_manager

    def init
      self.bank_payment_request = params[:payment_request]
      self.payment_order = bank_payment_request.payment_order
      self.bank_wallet_balance = AccountManager::Balance::Check.(user.bank_wallet).balance rescue 0
      self.actions = retrieve_actions
      self.manager = User::Team::Approver.(bank_payment_request.owner, payment_request: bank_payment_request, type: :manager)
      self.finance_manager = User::Team::Approver.(bank_payment_request.owner, payment_request: bank_payment_request, type: :finance_manager)
    end

    def retrieve_actions
      actions = {}
      associated_users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.controlling_user) rescue []
      if admin_view? && user.vendor_payments_admin?
        if bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id
          actions[:credit] = true
          balance = retrieve_balance(:vendor_payment_wallet, user)
          enabled = false
          admin = false
          if balance > bank_payment_request.requested_amount_value
            enabled = true
          end
          if user.vendor_payments_admin?
            admin = true
          end
          admins = []
          user.company.users.only_vendor_payment_admins.each do |admin|
            admins << {
                id: admin.id,
                name: admin.name
            }
          end
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money or Company Credits",
                  require_password: true,
                  initiating_account: true,
                  method: "patch"
              },
              approve_forward: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
                  messages: "You can forward this payment request to another admin to credit it",
                  enabled: true,
                  require_password: true,
                  button_type: "dropdown",
                  users: admins,
                  method: "patch",
                  type: 7
              }
          }
        elsif bank_payment_request.processing?
          actions[:take_control] = {method: "patch", type: 6, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        elsif bank_payment_request.open? && bank_payment_request.owner_id == user.id
          actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:destroy] ={method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
        elsif bank_payment_request.approved?
          actions[:credit] = true
          balance = retrieve_balance(:vendor_payment_wallet, user)
          enabled = false
          admin = false
          if balance > bank_payment_request.requested_amount_value
            enabled = true
          end
          if user.vendor_payments_admin?
            admin = true
          end
          admins = []
          user.company.users.only_vendor_payment_admins.each do |admin|
            admins << {
                id: admin.id,
                name: admin.name
            }
          end
          actions[:credit_options] = {
              credit: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request),
                  enabled: true,
                  messages: "You can directly credit this payment order from your Finly Money or Company Credits",
                  require_password: true,
                  initiating_account: true,
                  method: "patch"
              },
              approve_forward: {
                  url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
                  messages: "You can forward this payment request to another admin to credit it",
                  enabled: true,
                  require_password: true,
                  button_type: "dropdown",
                  users: admins,
                  method: "patch",
                  type: 7
              }
          }
        end
      elsif (manager_view?) && bank_payment_request.processing?
        if bank_payment_request.controlling_user_id == user.id
          actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:credit] = true
          balance = retrieve_balance(:vendor_payment_wallet, user)
          enabled = false
          admin = false
          if balance > bank_payment_request.requested_amount_value
             enabled = true
          end
          if user.vendor_payments_admin?
            admin = true
          end
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
          op = User::Team::Review::NextReviewer.(bank_payment_request)
          reviewer = op.user
          if reviewer.nil?
            button_type = "dropdown"
            message = "You can forward this request to another admin for them to credit it"
            admins = []
            user.company.users.only_vendor_payment_admins.each do |user|
              admins << {
                  id: user.id,
                  name: user.name
              }
            end
          else
            button_type = "button"
            message = "The payment request will move to #{reviewer.name} for approval"
            admins = []
            actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          end
          if reviewer.nil?
            actions[:credit_options][:approve_forward] = {
                url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
                messages: message,
                enabled: true,
                require_password: true,
                button_type: button_type,
                users: admins,
                method: "patch",
                type: 7
            }
          end
        elsif associated_users.include?(user)
          actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        end
      elsif finance_view? && bank_payment_request.processing?
        if bank_payment_request.controlling_user_id == user.id
          actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:credit] = true
          balance = retrieve_balance(:vendor_payment_wallet, user)
          enabled = false
          admin = false
          if balance > bank_payment_request.requested_amount_value
            enabled = true
          end
          if user.vendor_payments_admin?
            admin = true
          end
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
          op = User::Team::Review::NextReviewer.(bank_payment_request)
          reviewer = op.user
          if reviewer.nil?
            button_type = "dropdown"
            admins = []
            user.company.users.only_vendor_payment_admins.each do |user|
              admins << {
                  id: user.id,
                  name: user.name
              }
            end
          else
            button_type = "button"
            admins = []
            actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          end
          if reviewer.nil?
            actions[:credit_options][:approve_forward] = {
                url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
                messages: "",
                enabled: true,
                require_password: true,
                button_type: button_type,
                users: admins,
                method: "patch",
                type: 7
            }
          end
        elsif associated_users.include?(user)
          actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        end
      elsif initiator_view?
        if (bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?) && (bank_payment_request.owner_id == user.id)
          actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:editable] = true
          actions[:destroy] = {method: "delete", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
          balance = retrieve_balance(:vendor_payment_wallet, user)
          credit_enabled = false
          admin = false
          if balance > bank_payment_request.requested_amount_value
            credit_enabled = true
          end
          if user.vendor_payments_admin?
            admin = true
          end
          actions[:credit] = credit_enabled
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
        elsif bank_payment_request.processing? && bank_payment_request.owner_id == user.id
          actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        end
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
      end
    end

  end
end