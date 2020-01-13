class PaymentFiles::Formats::IdfcBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :client_code, :debit_account_number

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.client_code = self.options[:client_code]
    self.debit_account_number = self.options[:debit_account_number]
  end

  def validate
    result = PaymentFiles::Formats::IdfcBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_idfc_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          self.client_code,
          self.debit_account_number,
          retrieve_transaction_type_code(payment[:beneficiary_ifsc]),
          Date.today.strftime('%d-%m-%Y'),
          payment[:amount],
          payment[:beneficiary_account_name],
          payment[:beneficiary_account_number],
          payment[:beneficiary_ifsc],
          "",
          payment[:receiving_user_email],
          payment[:receiving_mobile_number],
          payment[:note],
          payment[:payment_mode].upcase,
          "OTH",
          "",
          "",
          "",
          "",
          "INR"
      ]
    end
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end

  def retrieve_idfc_headers
    [
        "Client Code",
        "Debit Account No.",
        "Transaction Type Code",
        "Value Date",
        "Payment Amount",
        "Beneficiary Name",
        "Beneficiary Account No.",
        "Beneficiary Bank Swift Code / IFSC Code",
        "Customer Reference No",
        "Beneficiary E-mail Id",
        "Beneficiary Phone No",
        "Remarks",
        "Message Type",
        "Purpose Code",
        "Beneficiary Account Type",
        "Pay At Location",
        "Print Branch",
        "Mode of Delivery",
        "Transaction Currency",
        "Beneficiary Addr. Line 1",
        "Beneficiary Addr. Line 2",
        "Beneficiary Addr. Line 3",
        "Beneficiary Addr. Line 4",
        "Beneficiary ID",
        "Remote Printing",
        "Print Branch Location",
        "Nature of Payment",
        "PoA Flag",
        "POA Account",
        "Mode of UPI Payment",
        "Virtual Payment Address",
        "Remitter VPA"
    ]
  end

  def retrieve_transaction_type_code(ifsc)
    type_code = ""
    if ifsc.present?
      type_code = ifsc.upcase[0..3] == 'IDFB' ? 'BT' : 'LBT'
    end
    type_code
  end
end