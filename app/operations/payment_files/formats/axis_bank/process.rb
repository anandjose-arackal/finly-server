class PaymentFiles::Formats::AxisBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
  end

  def validate
    result = PaymentFiles::Formats::AxisBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_axis_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          payment[:receiving_user_name],
          payment[:beneficiary_account_name],
          payment[:beneficiary_account_number],
          payment[:beneficiary_ifsc],
          retrieve_report_amount,
          retrieve_report_data(payment)
      ]
    end
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end

  def retrieve_axis_headers
    [
        "Name",
        "Bank",
        "Account No.",
        "IFSC Code",
        "Amount (Rs.)",
        "Report IDs"
    ]
  end

  def retrieve_report_data(payment)
    if [2, 164].include? user.company.id # Satin CreditCare or L&C
      return payment[:report_id]
    else
      return payment[:report_ids]
    end
  end

  def retrieve_report_amount(payment)
    if [2, 164].include? user.company.id # Satin CreditCare or L&C
      return payment[:reimbursable_amount]
    else
      return payment[:amount]
    end
  end
end