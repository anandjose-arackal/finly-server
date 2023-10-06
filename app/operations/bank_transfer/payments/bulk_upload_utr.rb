class BankTransfer::Payments::BulkUploadUtr < BankTransfer::Payments::Base

  attr_accessor :payments_data, :file, :result_array, :headers, :all_payments, :update_payments,
                :new_transactions, :existing_transactions,
                :all_transactions, :bank_transaction_class, :payments, :file_payments

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
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
    self.bank_transaction_class = user.company.feature_subscription.bank_transaction_class

  end

  def validate
    if self.payments_data.empty?
      add_message :error, "Empty excel file uploaded"
    end

  end

  def pre_process
    payment_order_ids = user.company.payment_orders.where('created_at > ?', (Date.today - 6.month)).with_purpose_id(PaymentPurpose.ids_for(:vendor_payment, :advance_against_purchase_order, :utility_bill_payment)).pluck(:id)
    self.all_payments = Payment.where(payment_status_id: [1,2,8]).with_payment_order_id(payment_order_ids).to_a
  end

  def process
    self.new_transactions = []
    self.existing_transactions = []
    self.payments = []
    self.file_payments = [] # it stores only successfully utr updated payments

    self.payments_data.each_with_index do |payment_data, index|
      self.result_array << payment_data.values
      id = payment_data[:payment_id]
      utr = payment_data[:utr]
      begin
        credited_at = nil
        credited_at = DateTime.strptime(payment_data[:processed_date], "%m/%d/%Y") if payment_data[:processed_date].present?
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
      unless payment.completed? || payment.failed?
        self.result_array[index] << "Only completed or failed payments can have an attached UTR"
        next
      end
      if (payment.reference_resources.present? && payment.utr.present?) || payment.utr.present?
        self.result_array[index] << "This payment already has an associated UTR"
        next
      end

      #removed reference resources updating logic, only updating payment object in case uploading UTR
      payment.utr  = utr
      payment.processed_at = credited_at
      payments << payment
      # add a success message to the result array
      self.file_payments.push(payment)
      self.result_array[index] << "Success!"
    end
    update_details
    self.file_payments.each do |payment|
      Payment.update_payment_status( payment, user )
    end
  end

  def post_process
    self.file_payments.each do |payment|
      if send_email_if_valid?(payment)
        BackgroundJobs::UtrUpdateEmail::SendInvoiceEmailOnUtrUpdateBackground.perform_async(payment&.id)
      end
    end
  end

  def success
    self.response = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.result_array}, messages)
  end


  private

  def send_email_if_valid?(payment)
    payment.present? and
    payment.utr.present? and
    payment.invoice.present? and
    payment.invoice.created_by.present? and
    SendInvoiceEmailOnUtrUpdateToggle.new(payment.invoice.created_by).enabled?
    # `SendInvoiceEmailOnUtrUpdateToggle` should be enabled since we are trying to send emails after `bulk UTR upload` action
  end

  def retrieve_headers
    [
        "Payment ID",
        "UTR",
        "Processed Date (MM/DD/YYYY)"
    ]
  end

  def update_details
    exec_statement self.payments, true, [:utr,:processed_at]
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