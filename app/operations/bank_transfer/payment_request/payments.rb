class BankTransfer::PaymentRequest::Payments < BankTransfer::PaymentRequest::Base

  attr_accessor :payments, :bank_payment_request

  class BankTransfer::PaymentRequest::Payments::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    require 'will_paginate/array'
    has_scope :filter_status_id
    has_scope :filter_search
    
    attr_accessor :payments, :payments_verified, :payments_unverified, :paginated_payments, :ordered_payments, :unpaid_payments

    def init
      self.payments = params[:payments]

      self.ordered_payments = self.payments
      # applying scopes for the payments list
      self.payments = apply_scopes(self.payments, params)

      # self.payments_unverified = []
      # self.payments_verified = []
      # # separating the verified and unverified payments
      # self.payments.each do |payment|
      #   if payment.receiving_user.is_a?(User) || payment.receiving_user.authorized
      #     self.payments_verified << payment
      #   else
      #     self.payments_unverified << payment
      #   end
      # end
      # self.ordered_payments = self.payments_verified + self.payments_unverified
      self.paginated_payments = self.payments.paginate(page: params[:page], per_page: (params[:per_page] || 10))
      if current_company.id == 118
        self.unpaid_payments = []
      else
        self.unpaid_payments = self.payments.unpaid
      end
    end

  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    index_params = params.select { |k,v| ["view", "role_id", :view, :role_id].include? k }
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, index_params).payment_requests.find_by(id: id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment ticket not found"
      return
    end
  end

  def process
    self.payments = self.bank_payment_request.payment_order.payments.include_for_index
  end

  def success
    params[:payments] = self.payments
    BankTransfer::PaymentRequest::Payments::PaymentsPresenter.new(user, params, messages)
  end
end