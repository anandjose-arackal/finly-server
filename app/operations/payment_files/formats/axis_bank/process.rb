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
    self.headers = retrieve_axis_headers
    content = []

    self.payment_file_data.each do |payment|
      content << [
          payment[:receiving_user_name],
          payment[:beneficiary_account_name],
          {value: payment[:beneficiary_account_number], type: 'string'},
          payment[:beneficiary_ifsc],
          {value: sprintf('%.2f', retrieve_report_amount(payment)), type: 'number'},
          retrieve_report_data(payment)
      ]
    end
    self.contents = content
  end

  def retrieve_axis_headers
    [
        "Name",
        "Bank",
        "Account No.",
        "IFSC Code",
        "Amount (Rs.)",
        "#{current_app == :em ? 'Report IDs' : 'Payment ID'}"
    ]
  end

  #@todo
  # the below hard coded logic need to move to personlizer
  def retrieve_report_data(payment)
    if [2, 164].include? user.company.id && current_app == :em # Satin CreditCare or L&C
      return payment[:report_id]
    elsif current_app == :vp
      return payment[:payment_id]
    end
  end

  def retrieve_report_amount(payment)
    if [2, 164].include? user.company.id && current_app == :em # Satin CreditCare or L&C
      return payment[:reimbursable_amount]
    else
      return payment[:amount]
    end
  end

  def success
    generate_export_file
  end
end