# this operation will initiate a 1Rs transaction in the background machine and
# return the data back to the application server that requested for it
class YesBankTransferProvider
  include Sidekiq::Worker
  sidekiq_options queue: :payments_critical_queue

  attr_accessor :account_number, :ifsc, :company_id

  def perform(response_handle, params)
    queue = Struct.new(:queue).new(response_handle)

    indifferent_params = params.with_indifferent_access

    # This is a temporary patch for issue https://sentry.finly.io/organizations/finly/issues/642
    # Basically, the return value of +YesBankTransaction.find_by+ was nil. When we were checking this in console a few minutes later, it was available
    # Our best guess is that the job was being executed before the transaction could be persisted to the database
    # leading to the above issue.

    bank_transaction = YesBankTransaction.find_by(id: indifferent_params[:bank_transaction_id])

    indifferent_params[:attempts] ||= 0

    if bank_transaction.blank? and indifferent_params[:attempts] <= 5
      indifferent_params[:attempts] += 1
      YesBankTransferProvider.perform_in(1.minute, response_handle, params)

      return
    end

    Raven.extra_context transaction_id: indifferent_params[:bank_transaction_id],
                        params: indifferent_params,
                        record: YesBankTransaction.find_by(id: indifferent_params[:bank_transaction_id])

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

      # # temporary jugaad to test this shizzle out
      # Resque.enqueue(queue, {success: true, full_name: "Sreeram N R", bank_transaction_id: bank_transaction.id})
      # return

      ########################################
      op = YesBankApi::Transfer::BankTransfer.({
          transfer_request: transfer_request,
          bank_transaction: bank_transaction
      })

      # updating the bank transaction with the new details
      bank_transaction.update(
          bank_reference_number: transfer_request.bank_reference_number,
          transfer_status_id: op.transfer_status_id,
          bank_response: transfer_request.transaction_result,
          beneficiary_full_name: transfer_request.beneficiary_full_name
      )

      # return the balance given by the API
      if op.success? && !bank_transaction.beneficiary_full_name.blank?
        full_name = bank_transaction.beneficiary_full_name
        Resque.enqueue(queue, {success: true, full_name: full_name, bank_transaction_id: bank_transaction.id})
      else
        error_message = op.transfer_request.bank_error_message || op.messages&.dig(:error)
        if op.messages&.dig(:error).blank?
          error_message = "This is not a valid bank account number"
        end
        Resque.enqueue(queue, {success: false, full_name: "", bank_transaction_id: nil, messages: error_message})
      end
    rescue Exception => e
      Resque.enqueue(queue, {success: false, full_name: "", bank_transaction_id: nil, messages: e.message})
    end
  end


  private

  # this method will create a transfer request for a penny transfer to the beneficiary account
  def create_transfer_request(transfer_type, reference_number)
    tr = YesBankTransferRequest.("BankAccount", self.account_number, self.ifsc, 1, transfer_type, reference_number, self.company_id)
  end
end
