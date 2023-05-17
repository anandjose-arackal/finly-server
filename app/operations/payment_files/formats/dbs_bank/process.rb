class PaymentFiles::Formats::DbsBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :product_code, :debit_account_number

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
    self.product_code = self.options[:product_code]
  end

  def validate
    result = PaymentFiles::Formats::DbsBank::ValidateConfig.(user, {options: self.options, config: self.config})
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
          self.product_code,
          "",
          self.product_code,
          {value: sprintf('%.2f', payment[:amount]), type: 'number'},
          self.debit_account_number,
          "I",
          payment[:beneficiary_ifsc],
          payment[:receiving_user_name],
          "",
          "",
          "",
          "",
          "",
          "",
          {value: payment[:beneficiary_account_number], type: 'string'},
      ]
    end
    self.contents = content
  end

  def retrieve_axis_headers
    [
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