class PaymentFiles::Formats::KarnatakaBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
  end

  def validate
    result = PaymentFiles::Formats::KarnatakaBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_kbl_headers
    content = []
    sl_no = 0
    self.payment_file_data.each do |payment|
      sl_no += 1
      content << [
          sl_no,
          payment[:date],
          self.debit_account_number,
          payment[:amount],
          payment[:beneficiary_ifsc],
          '',
          payment[:beneficiary_account_number],
          payment[:receiving_user_name],
          '',
          '',
          payment[:note],
          payment[:receiving_mobile_number],
          payment[:receiving_mobile_number]
      ]
    end
    self.contents = content
  end

  def success
    generate_export_file
  end

  def retrieve_kbl_headers
    [
        'Srl No',
        'Date',
        'Debit account number',
        'Amount',
        'Benificiary IFSC code',
        'Branch Name',
        'Beneficiary Account Number',
        'Beneficiary Name',
        'Beneficiary Address Benf',
        'Address 1',
        'Details of payment',
        'Debit conf - Mob',
        'Mobile number'
    ]
  end
end