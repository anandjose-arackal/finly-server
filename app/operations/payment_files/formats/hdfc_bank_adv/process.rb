class PaymentFiles::Formats::HdfcBankAdv::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :transaction_type, :beneficiary_email

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.beneficiary_email = self.options[:beneficiary_email]
  end

  def validate
    result = PaymentFiles::Formats::HdfcBank::ValidateConfig.(user, {options: self.options, config: self.config, payment_file: params[:payment_file]})
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

  def process
    self.headers = retrieve_hdfc_headers
    content = []
    self.payment_file_data.each do |payment|
      if self.options[:transaction_type].nil?
        self.transaction_type = (payment[:beneficiary_ifsc]&.include?("HDFC") ? "I" : "N")
      end
      content << [
          self.transaction_type,
          (self.transaction_type == "I" ? payment[:beneficiary_account_number] : ''),
          {value: payment[:beneficiary_account_number], type: 'string'},
          {value: sprintf('%.2f', payment[:amount]), type: 'number'},
          payment[:receiving_user_name],
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          payment[:receiving_user_name],
          payment[:receiving_user_name],
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          Date.parse(payment[:date].to_s).strftime('%d/%m/%Y'),
          '',
          payment[:beneficiary_ifsc],
          (self.transaction_type == "I" ? "HDFC Bank" : payment[:beneficiary_account_name]),
          '',
          self.beneficiary_email
      ]
    end
    self.contents = content
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

  def success
    generate_export_file
  end

end