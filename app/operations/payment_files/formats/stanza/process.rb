class PaymentFiles::Formats::Stanza::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
  end

  def validate
    result = PaymentFiles::Formats::Stanza::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_axis_headers
    content = []
    count = 1
    self.payment_file_data.each do |payment|
      content << [
          count,
          payment[:employee_id],
          payment[:receiving_user_name],
          payment[:beneficiary_ifsc],
          payment[:beneficiary_account_number],
          payment[:note],
          payment[:amount],
          payment[:approved_by],
          payment[:cost_center],
          payment[:period],
          payment[:email]
      ]
    end
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end

  def retrieve_axis_headers
    [
        "S.No",
        "Employee Code",
        "Vendor/ Benificary Details",
        "IFSC Code",
        "Account No",
        "Description",
        "Amount",
        "Approved By",
        "Cost Center",
        "Period",
        "Empolyee Email ID"
    ]
  end

end