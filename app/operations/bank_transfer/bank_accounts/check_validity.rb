# this operation will do a penny transfer to the passed account number and
# does a penny transfer to retrieve the beneficiary name with the bank
class BankTransfer::BankAccounts::CheckValidity < BankTransfer::BankAccounts::Base

  attr_accessor :account_number, :bank_transaction, :company, :transfer_request,
                :ifsc

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
  end

  def process
    op = YesBankApi::Transfer::BankTransfer.({
        transfer_request: self.transfer_request,
        bank_transaction: self.bank_transaction
    })
    # now's the interesting bit. Based on the data sent by the API we have to handle the different cases
    if op.success?
      if bank_transaction.completed?
        self.full_name = self.bank_transaction.beneficiary_full_name
      else
        add_message :error, "Could not reach beneficiary bank servers. Please try again later"
      end
    else
      error_message = op.transfer_request.bank_error_message || op.messages&.dig(:error) || "Could not reach beneficiary bank servers. Please try again later"
      add_message :error, error_message
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