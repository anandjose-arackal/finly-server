# this operation will initiate a 1Rs transaction in the background machine and
# return the data back to the application server that requested for it
class YesBankTransferProvider
  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  attr_accessor :account_number, :ifsc, :company_id

  def perform(response_handle, params)
    queue = Struct.new(:queue).new(response_handle)

    indifferent_params = params.with_indifferent_access
    bank_transaction = BankTransaction.find_by(id: indifferent_params[:bank_transaction_id])
    self.account_number = indifferent_params[:account_number]
    self.ifsc = indifferent_params[:ifsc]
    company = bank_transaction.company
    self.company_id = company&.id
    transfer_request = create_transfer_request("IMPS", bank_transaction.unique_request_number)
    queue = Struct.new(:queue).new(response_handle)
    begin
      if company.blank?
        # Respond failure
        Resque.enqueue(queue, {success: false, message: 'Company not found'})
        return
      end
      user = company.users.first
      if user.blank?
        # Respond failure
        Resque.enqueue(queue, {success: false, message: 'Company not found'})
        return
      end

      # temporary jugaad to test this shizzle out
      Resque.enqueue(queue, {success: true, full_name: "Sreeram N R", bank_transaction_id: bank_transaction.id})
      return
      
      ########################################
      op = YesBankApi::Transfer::BankTransfer.({
          transfer_request: transfer_request,
          bank_transaction: bank_transaction
      })
      # return the balance given by the API
      if op.success?
        full_name = self.bank_transaction.beneficiary_full_name
        Resque.enqueue(queue, {success: true, full_name: full_name, bank_transaction_id: bank_transaction.id})
      else
        error_message = op.transfer_request.bank_error_message || op.messages&.dig(:error) || "Could not reach beneficiary bank servers. Please try again later"
        Resque.enqueue(queue, {success: false, full_name: "", bank_transaction_id: nil, messages: error_message})
      end
    rescue Exception => e
      Resque.enqueue(queue, {success: false, full_name: 0, bank_transaction_id: nil, messages: e.message})
    end
  end


  private

  # this method will create a transfer request for a penny transfer to the beneficiary account
  def create_transfer_request(transfer_type, reference_number)
    tr = TransferRequest.("BankAccount", self.account_number, self.ifsc, 0.1, transfer_type, reference_number, self.company_id)
  end
end