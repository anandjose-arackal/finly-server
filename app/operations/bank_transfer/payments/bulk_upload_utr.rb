class BankTransfer::Payments::BulkUploadUtr < BankTransfer::Payments::Base

  attr_accessor :payments_data, :file, :result_array, :headers

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
    self.payments_data = ImportUtil.load_spreadsheet(file, [:payment_id, :utr], {skip_empty_lines: true})
    self.result_array = []
    self.headers = retrieve_headers
  end

  def validate
    if self.payments_data.empty?
      add_message :error, "Empty excel file uploaded"
    end

  end

  def process
    self.payments_data.each_with_index do |payment_data, index|
      self.result_array << payment_data.values
      id = payment_data[:payment_id]
      utr = payment_data[:utr]
      payment_order_ids = user.company.payment_orders.with_purpose_id(PaymentPurpose.id_for(:vendor_payment)).pluck(:id)
      payment = Payment.with_payment_order_id(payment_order_ids).find_by(id: id)
      if payment.blank?
        self.result_array[index] << "This payment already has an associated UTR"
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
      if payment.reference_resource.present? && payment.reference_resource&.is_a?(BankTransaction)
        payment.reference_resource.update(bank_reference_number: utr)
      else
        # create a bank transaction for this particular payment
        bank_transaction = BankTransaction.create(transfer_type: payment.payment_mode,
                                                  bank_reference_number: utr,
                                                  company_id: user.company_id,
                                                  transfer_status_id: BankTransferStatus.id_for(:completed),
                                                  bank_transaction_type_id: BankTransactionType.id_for(:outside_finly),
                                                  beneficiary_bank_account_id: payment.receiving_account.id,
                                                  amount_attributes: {value: payment.amount_value, currency_id: 1})
        payment.update(reference_resource: bank_transaction)
      end
      # add a success message to the result array
      self.result_array[index] << "Success!"
    end
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
        "UTR"
    ]
  end

end