class PaymentFiles::Formats::HdfcBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests#, :customer_reference_number

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    # self.customer_reference_number = self.options[:customer_reference_number]
  end

  def validate
    result = PaymentFiles::Formats::HdfcBank::ValidateConfig.(user, {options: self.options, config: self.config, payment_file: params[:payment_file]})
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

  def process
    headers = retrieve_hdfc_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          'I',
          '',
          payment[:beneficiary_account_number],
          sprintf('%.2f',payment[:amount]),
          payment[:receiving_user_name],
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          payment[:date].strftime('%d/%m/%Y'),
          '',
          payment[:beneficiary_ifsc],
          payment[:beneficiary_account_name],
          '',
          payment[:receiving_user_email]
      ]
    end
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end

  def retrieve_hdfc_headers
    [
        'Transaction Type',
        'Beneficiary Code',
        'Beneficiary Account Number',
        'Transaction Amount',
        'Beneficiary Name',
        'Drawee Location in case of Demand Draft',
        'DD Printing Location',
        'Beneficiary Address 1',
        'Beneficiary Address 2',
        'Beneficiary Address 3',
        'Beneficiary Address 4',
        'Beneficiary Address 5',
        'Instruction Reference Number',
        'Customer Reference Number',
        'Payment details 1',
        'Payment details 2',
        'Payment details 3',
        'Payment details 4',
        'Payment details 5',
        'Payment details 6',
        'Payment details 7',
        'Cheque Number',
        'Chq / Trn Date',
        'MICR Number',
        'IFS Code',
        'Beneficery Bank Name',
        'Beneficiary Bank Branch Name',
        'Beneficiary email id'
    ]
  end
end