class BankTransfer::Payments::BulkUploadUtr < BankTransfer::Payments::Base

  attr_accessor :payments_data, :file, :result_array, :headers, :all_payments, :update_payments, :new_transactions, :existing_transactions,
                :all_transactions

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invaoid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.file = params[:file]
    self.payments_data = ImportUtil.load_spreadsheet_quickly(file, [:payment_id, :utr, :processed_date], {skip_empty_lines: true})
    self.result_array = []
    self.headers = retrieve_headers
  end

  def validate
    if self.payments_data.empty?
      add_message :error, "Empty excel file uploaded"
    end

  end

  def pre_process
    payment_order_ids = user.company.payment_orders.with_purpose_id(PaymentPurpose.ids_for(:vendor_payment, :advance_against_purchase_order)).pluck(:id)
    self.all_payments = Payment.with_payment_order_id(payment_order_ids).to_a
    self.all_transactions = YesBankTransaction.where(company_id: user.company_id).pluck(:bank_reference_number)
  end

  def process
    self.new_transactions = []
    self.existing_transactions = []
    self.update_payments = []

    self.payments_data.each_with_index do |payment_data, index|
      self.result_array << payment_data.values
      id = payment_data[:payment_id]
      utr = payment_data[:utr]
      begin
        credited_at = nil
        credited_at = DateTime.strptime(payment_data[:processed_date], "%d-%m-%Y") if payment_data[:processed_date].present?
        credited_at += Time.now&.seconds_since_midnight&.seconds unless credited_at.nil?
        #XLSX library read the date in MM-DD-YYYY format, Rewrite the date in supplied format after processing.
        self.result_array.last[-1] = credited_at&.strftime("%m/%d/%Y")
      rescue ArgumentError => e
        self.result_array[index] << "Invalid Processed Date"
        next
      end
      # payment = Payment.with_payment_order_id(payment_order_ids).find_by(id: id)
      payment = self.all_payments.find { |payment| payment if payment.id.to_i == id.to_i }
      if payment.blank?
        self.result_array[index] << "This payment was not found."
        next
      end
      unless payment.completed?
        self.result_array[index] << "Only completed payments can have an attached UTR"
        next
      end
      if payment.reference_resource.present? && payment.reference_resource.bank_reference_number.present?
        self.result_array[index] << "This payment already has an associated UTR"
        next
      end
      if payment.reference_resource.present? && payment.reference_resource&.is_a?(YesBankTransaction)
        # payment.reference_resource.update(bank_reference_number: utr)
        reference_resource = payment.reference_resource
        reference_resource.bank_reference_number = utr
        existing_transactions << reference_resource
      else
        # disallow duplicate utr to be updated
        if self.all_transactions.include? utr.to_s.strip
          p_id = YesBankTransaction.where(company_id: user.company_id, bank_reference_number: utr).first&.payment&.id
          self.result_array[index] << "UTR already exists for some other payment. See Payment ID - #{p_id}"
          next
        elsif self.payments_data[0, index].to_a.pluck(:utr).include? utr.to_s.strip
          p_id = self.payments_data[0, index].find {|data| data if data[:utr] == utr.to_s.strip}
          self.result_array[index] << "UTR already exists for some other payment. See Payment ID - #{p_id[:payment_id]}"
          next
        end
        # create a bank transaction for this particular payment
        amount = Amount.create(value: payment.amount_value, currency_id: 1)
        new_transactions << YesBankTransaction.new(transfer_type: payment.payment_mode,
                                                   bank_reference_number: utr,
                                                   company_id: user.company_id,
                                                   transfer_status_id: BankTransferStatus.id_for(:completed),
                                                   bank_transaction_type_id: BankTransactionType.id_for(:outside_finly),
                                                   beneficiary_bank_account_id: payment.receiving_account&.id,
                                                   amount_id: amount.id,
                                                   created_at: credited_at)
        # payment.update(reference_resource: bank_transaction)
        payment.reference_resource = new_transactions.last
        self.update_payments << payment
      end
      # add a success message to the result array
      self.result_array[index] << "Success!"
    end
    update_details
  end

  def post_process

  end

  def success
    self.response = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.result_array}, messages)
  end


  private

  def retrieve_headers
    [
        "Payment ID",
        "UTR",
        "Processed Date (MM/DD/YYYY)"
    ]
  end

  def update_details
    exec_statement self.existing_transactions, true, [:bank_reference_number]
    exec_statement self.new_transactions
    payments_without_transactions = payment_details
    exec_statement payments_without_transactions, true, [:reference_resource_id, :reference_resource_type]
  end

  def payment_details
    transactions = []
    utrs = self.new_transactions.pluck :bank_reference_number
    newly_created_transactions = YesBankTransaction.where bank_reference_number: utrs
    transactions = []
    utrs.each do |utr|
      transactions << newly_created_transactions.find {|transaction| transaction if transaction.bank_reference_number == utr}
    end
    return false if transactions.blank?

    payments = []
    transactions.each_with_index do |transaction, index|
      next if transaction.blank?
      payment = self.update_payments.find {|payment| payment if payment.reference_resource.bank_reference_number == transaction.bank_reference_number}
      payment.reference_resource_type = 'YesBankTransaction'
      payment.reference_resource_id = transaction.id
      payments << payment
    end
    payments
  end

  def exec_statement(batch, update=false, keys=[])
    if batch.blank?
      puts "Batch is empty."
      return
    end

    begin
      runner batch, update, keys
      true
    rescue => e
      puts "Error importing the bulk. Reason #{e.message}"
      false
    end
  end

  def runner(batch, update=false, keys)
    klass = batch.first.class
    if update
      klass.import batch, on_duplicate_key_update: keys, validate: false
    else
      klass.import batch, validate: false
    end
  end

end