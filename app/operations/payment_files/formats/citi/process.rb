class PaymentFiles::Formats::Citi::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
  end

  def validate
    result = PaymentFiles::Formats::Citi::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_citi_headers
    content = []
    pos = 0
    self.payment_file_data.each do |payment|
      content << [
          self.debit_account_number,
          Date.today.strftime('%Y%m%d'),
          (pos += 1),
          payment[:receiving_user_name],
          'EFT',
          payment[:beneficiary_account_number],
          payment[:beneficiary_ifsc],
          1,
          payment[:amount],
          payment[:note]
      ]
    end
    self.contents = content
  end

  def retrieve_citi_headers
    [
        "Debit Account Number",
        "Value Date",
        "Customer Reference Number",
        "Beneficiary Name",
        "Payment Type",
        "Bene Account Number",
        "Bank Code",
        "Account Type",
        "Amount",
        "Payment Details 1"
    ]
  end

  def success
    generate_export_file
  end

end