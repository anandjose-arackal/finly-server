class PaymentFiles::Formats::CitiBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
  end

  def validate
    result = PaymentFiles::Formats::CitiBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_citi_bank_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          payment[:beneficiary_ifsc],
          "",
          payment[:beneficiary_account_number],
          payment[:receiving_user_name],
          payment[:amount],
          "",
          "",
          ""
      ]
    end
    self.contents = content
  end

  def retrieve_citi_bank_headers
    [
        "IFSC Code",
        "A/c Type",
        "Beneficiary ACNO",
        "Beneficiary Name",
        "Amount",
        "Financial Text",
        "Branch Code",
        "Validation Status"
    ]
  end

  def success
    generate_export_file
  end

end