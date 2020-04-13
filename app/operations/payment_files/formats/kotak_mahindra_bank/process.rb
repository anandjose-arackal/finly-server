class PaymentFiles::Formats::KotakMahindraBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number, :client_code, :product_code, :bank_code_indicator, :hide_note

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
    self.client_code = self.options[:client_code]
    self.product_code = self.options[:product_code]
    self.bank_code_indicator = self.options[:bank_code_indicator] rescue ''
    self.hide_note = self.options[:hide_note] rescue false
  end

  def validate
    result = PaymentFiles::Formats::KotakMahindraBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_kotak_headers
    content = []
    sl_no = 0
    self.payment_file_data.each do |payment|
      sl_no += 1
      content << [
          self.client_code,
          product_code,
          payment[:payment_mode],
          "",
          payment[:date]&.strftime("%d/%m/%Y"),
          self.debit_account_number,
          payment[:amount],
          "",
          payment[:receiving_user_name],
          payment[:beneficiary_ifsc],
          payment[:beneficiary_account_number],
          payment[:receiving_user_email],
          payment[:receiving_mobile_number],
          retrieve_note(payment[:note])
      ]
    end
    self.contents = content
  end

  def success
    generate_export_file
  end

  def retrieve_kotak_headers
    [
        "Client_Code",
        "Product_Code",
        "Payment_Type",
        "Payment_Ref_No.",
        "Payment_Date (Mention in dd/mm/yyyy) format",
        "Dr_Ac_No",
        "Amount",
        "Beneficiary_Code",
        "Beneficiary_Name",
        "IFSC Code",
        "Beneficiary_Acc_No",
        "Beneficiary_Email",
        "Beneficiary_Mobile",
        "Debit_Narration",
        "Credit_Narration",
        "Enrichment_1",
        "Enrichment_2",
        "Enrichment_3",
        "Enrichment_4"
    ]
  end

  def retrieve_note(note)
    self.hide_note ? '' : note
  end

end