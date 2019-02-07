require 'resque'
class Admin::BankTransfer::GetStatus < Admin::Base

  attr_accessor :bank_transaction, :unique_request_number, :status

  def pre_validate
    super()
    if params.blank?
      add_message :error, "Invalid params, try again"
      return
    end
  end

  def init
    if params["unique_request_number"]
      self.unique_request_number = params["unique_request_number"]
      self.bank_transaction = BankTransaction.find_by(unique_request_number: self.unique_request_number)
      self.bank_transaction = BankTransaction.find_by(bank_reference_number: self.unique_request_number) if self.bank_transaction.blank?
      if self.bank_transaction.nil?
        payment = Payment.find_by(id: self.unique_request_number.to_i)
        if payment.present? and payment.reference_resource_type == 'BankTransaction'
          self.bank_transaction = payment.reference_resource
        end
      end
    end
  end

  def validate
    if self.bank_transaction.blank?
      add_message :error, "Transaction with this request number not found"
      return
    end
  end

  def process
    params = {
        request_reference_number: bank_transaction.unique_request_number,
        company_id: bank_transaction.company_id,
        unique_request_number: bank_transaction.unique_request_number,
        transfer_type: bank_transaction.transfer_type
    }
    handle = self.object_id
    YesBankStatusProvider.perform_async(handle, params)
    timeout = 30
    now = Time.now
    while (Time.now - now) < timeout
      result = Resque.reserve(handle)
      next if result.blank?
      args = result.args.first
      success = args&.dig('success')
      message = args&.dig('messages')
      binding.pry
      if success
        self.status = args['status']
      end
      add_message :error, message if message
      break
    end
  end

  def success
    params[:transaction] = self.bank_transaction
    params[:status] = self.status
    Admin::BankTransfer::GetStatus::StatusSuccessPresenter.new(user,params, messages)
  end

  def failure
    Admin::BankTransfer::GetStatus::StatusFailurePresenter.new(user,nil, messages)
  end

  class Admin::BankTransfer::GetStatus::StatusSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transaction, :status

    def init
       self.transaction = params[:transaction]
       self.status = params[:status]
    end
  end

  class Admin::BankTransfer::GetStatus::StatusFailurePresenter < BaseOperation::BasePresenter::SuccessPresenter

  attr_accessor :transaction, :status

    def init
      self.transaction = nil
      self.status = nil
    end
  end

end