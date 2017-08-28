# operation that loads all the details about the payment request

class BankTransfer::PaymentRequest::Show < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:payment_request_id]
    # todo - implement the below index operation to determine who can be in the list of people with access to the payment request
    # self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
    self.bank_payment_request = BankPaymentRequest.find_by(id: id)
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

    attr_accessor :bank_payment_request, :payment_order, :actions, :bank_wallet_balance

    def init
      self.bank_payment_request = params[:payment_request]
      self.payment_order = bank_payment_request.payment_order
      self.bank_wallet_balance = AccountManager::Balance::Check.(user.bank_wallet).balance rescue 0
      self.actions = retrieve_actions
    end

    def retrieve_actions
      actions = {}
      if admin_view?
        if bank_payment_request.processing? && bank_payment_request.controlling_user_id == user.id
          actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        elsif bank_payment_request.processing?
          actions[:take_control] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        elsif bank_payment_request.open? && bank_payment_request.owner_id == user.id
          actions[:submit] = actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:destroy] = actions[:destroy] = {method: "destroy", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
        elsif bank_payment_request.approved?
          actions[:credit] = actions[:credit] = {method: "patch", url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request)}
        end
      elsif finance_view? || manager_view?
        actions[:approve] = {method: "patch", type: 1, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:reject] = {method: "patch", type: 4, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:unapprove] = {method: "patch", type: 5, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        actions[:credit] = {method: "patch", url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request)}
      else
        if bank_payment_request.open? || bank_payment_request.rejected? || bank_payment_request.retracted?
          actions[:submit] = {method: "patch", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
          actions[:editable] = true
          actions[:destroy] = {method: "destroy", type: 2, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_path(bank_payment_request)}
          if bank_wallet_balance >= bank_payment_request.requested_amount_value && bank_payment_request.initiating_account == user.bank_wallet
            actions[:credit] = {method: "patch", url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_credit_path(bank_payment_request)}
          end
        elsif bank_payment_request.processing?
          actions[:retract] = {method: "patch", type: 3, url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request)}
        end
      end
      actions
    end
  end
end