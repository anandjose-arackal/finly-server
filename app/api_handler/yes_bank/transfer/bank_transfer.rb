class YesBank::Transfer::BankTransfer < YesBank::Base

  attr_accessor :account_number, :ifsc, :beneficiary_name, :beneficiary_account_number, :beneficiary_ifsc, :transfer_currency,
                :transfer_type, :transfer_amount, :transfer_request, :body_xml

  def initialize(transfer_request)
    self.transfer_request = transfer_request
  end

  def self.call(transfer_request)
    self.new(transfer_request).run
  end

  # defines the respective action that this API handler is executing
  def yes_bank_action
    'transfer'
  end

  def pre_validate
    if transfer_request.blank?
      add_message :error, "Invalid parameters"
      return
    end

    unless transfer_request.class.name == "TransferRequest"
      add_message :error, "Invalid parameters"
    end

    unless transfer_request.valid?
      add_message :error, transfer_request.errors
      return
    end
  end

  def init
    super()
    self.account_number = YAML.load_file(config_path)[Rails.env]['account_number']
    self.ifsc = transfer_request.ifsc
    self.beneficiary_account_number = transfer_request.beneficiary_account_number
    self.beneficiary_name = transfer_request.beneficiary_name
    self.beneficiary_ifsc = transfer_request.ifsc
    self.transfer_currency = "INR" # todo - needs to be changed if multi-currency is implemented
    self.transfer_type = transfer_request.transfer_type
    self.transfer_amount = transfer_request.transfer_amount
    set_xml_params
  end

  def process
    p = self.path
    begin
      puts "Posting Path: #{p}"
      puts "Post Params: #{self.template}"

      self.response = self.connection.post do |req|
        req.url p
        req.headers['Content-Type'] = 'application/xml'
        req.headers['X-IBM-Client-Id'] = client_id
        req.headers['X-IBM-Client-Secret'] = client_secret
        req.body = template
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      self.timeout = true
      add_message :error, "Request timed out. Please try again"
    end
  end

  def success?

  end

  def failure?

  end

  private

  def set_xml_params
    liquid_template = load_soap_template
    self.template = liquid_template.render(
        'UNIQUE_REFERENCE_NUMBER' => generated_reference_number,
        'APP_ID' => application_id,
        'CUSTOMER_ID' => customer_id,
        'ACCOUNT_NUMBER' => account_number,
        'BENEFICIARY_NAME' => beneficiary_name,
        'BENEFICIARY_ACCOUNT_NUMBER' => beneficiary_account_number,
        'BENEFICIARY_IFSC' => beneficiary_ifsc,
        'TRANSFER_TYPE' => transfer_type,
        'TRANSFER_CURRENCY_CODE' => transfer_currency,
        'TRANSFER_AMOUNT' => transfer_amount
    )
  end

  def generated_reference_number

  end
end