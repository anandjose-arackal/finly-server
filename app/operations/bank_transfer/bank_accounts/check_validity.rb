# this operation will do a penny transfer to the passed account number and
# does a penny transfer to retrieve the beneficiary name with the bank
class BankTransfer::BankAccounts::CheckValidity < BankTransfer::BankAccounts::Base

  attr_accessor :account_number, :bank_transaction, :company, :transfer_request,
                :ifsc, :bank_transaction_id, :bank_transaction, :full_name, :error_message,
                :name

  class BankTransfer::BankAccounts::CheckValidity::AccountNumberCheckPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :full_name, :account_number, :ifsc

    def init
      self.full_name = params[:full_name]
      self.account_number = params[:account_number]
      self.ifsc = params[:ifsc]
    end

  end



  def init
    self.account_number = params[:account_number]
    self.ifsc = params[:ifsc]
    self.name = params[:name]
    self.company = user.company
    # this will also create the bank transaction and TransferRequest non-persistent model
    # that is required for creating actually making the request with YesBank's servers
    self.transfer_request = create_transfer_request("IMPS", nil)
    self.bank_transaction = self.company.bank_transactions.create(
       unique_request_number: self.transfer_request.generate_unique_reference,
       transfer_type: "IMPS",
       bank_reference_number: self.transfer_request.bank_reference_number,
       transfer_status_id: BankTransferStatus.id_for(:open),
       account_name_check: true,
       amount_attributes: {
           value: 0.1,
           currency_id: Currency.first.id
       }
    )
  end

  def validate
    if self.account_number.blank?
      add_message :error, "No account number to check"
      return
    end

    if self.ifsc.blank?
      add_message :error, "IFSC cannot be empty"
      return
    end

    if bank_transaction.blank?
      add_message :error, "Invalid request, try again later"
      return
    end

    if self.company.blank?
      add_message :error, "Company cannot be blank"
      return
    end
  end

  def process
    handle = self.object_id
    params = {
        account_number: self.account_number,
        ifsc: self.ifsc,
        company_id: self.company.id,
        bank_transaction_id: self.bank_transaction.id
    }
    YesBankTransferProvider.perform_async(handle, params)
    timeout = 30
    now = Time.now
    while (Time.now - now) < timeout
      result = Resque.reserve(handle)
      next if result.blank?

      args = result.args.first
      success = args&.dig('success')
      message = args&.dig('message')
      return 0 unless success

      self.bank_transaction_id = args["bank_transaction_id"]
      self.full_name = args["full_name"]
      self.error_message = args["messages"]
    end


    if self.full_name.present?
      # #todo - this should create a bank account in the Bank Account Master first
    else
      add_message :error, error_message
      return
    end
  end

  def success
    params[:full_name] = self.full_name
    BankTransfer::BankAccounts::CheckValidity::AccountNumberCheckPresenter.new(user, params, messages)
  end

  private

  # this method will create a transfer request for a penny transfer to the beneficiary account
  def create_transfer_request(transfer_type, reference_number)
    tr = TransferRequest.("BankAccount", self.account_number, self.ifsc, 0.1, transfer_type, reference_number, self.company.id)
  end
end