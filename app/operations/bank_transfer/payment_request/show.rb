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

    attr_accessor :bank_payment_request, :payment_order, :actions

    def init
      self.bank_payment_request = params[:payment_request]
      self.payment_order = bank_payment_request.payment_order
      self.actions = retrieve_actions
    end

    def retrieve_actions
      actions = {}
      if personal_view? && bank_payment_request.owner_id == user.id
        editable = true
      elsif bank_payment_request.controlling_user_id == user.id
        editable = true
      else
        editable = false
      end
      # todo - logics for actions to be added
      {
          editable: editable,
          submit: {
              method: "patch",
              url: Rails.application.routes.url_helpers.bank_transfer_bank_payment_request_review_path(bank_payment_request),
              type: 2 # i.e. 2 is submit
          }
      }
    end
  end
end