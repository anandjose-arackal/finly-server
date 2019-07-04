class IciciBankApi::AccountStatement < IciciBankApi::Base

  attr_accessor :company, :start_date, :end_date

  def init
    super
    # here start date and end date are going to be date objects
    self.start_date = params[:start_date]&.strftime("%d-%m-%Y") || Date.yesterday.strftime("%d-%m-%Y")
    self.end_date = params[:end_date]&.strftime("%d-%m-%Y") || Date.today.strftime("%d-%m-%Y")
  end

  def initialize(company, params)
    self.company = company
    self.params = params
  end

  def self.call(company, params)
    self.new(company, params).run
  end

  def validate
    unless self.company.bank_service_provider == "ICICI"
      add_message :error, "You are not configured for ICICI transactions"
      return
    end
  end

  def env_key
    'icici_bank_account_statement'
  end

  def raw_api_params
    {
        AGGRID: self.company_details["AGGR_ID"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        ACCOUNTNO: self.company_details["DEBIT_ACC_NO"],
        FROMDATE: self.start_date.to_s,
        TODATE: self.end_date.to_s,
        URN: self.company.icici_bank_config.urn
    }
  end


  def post_params
    encrypt_params(
        raw_api_params
    )
  end

  def decrypt_response(body)
    path = Dir.home + '/certificates/icici_certificates_final/finly_icici_production.key'
    parsed_json = JSON.parse(body)
    private_key = OpenSSL::PKey::RSA.new(File.read(path))
    decrypted_key = private_key.private_decrypt(Base64.decode64(parsed_json["encryptedKey"]))
    decoded_data = Base64.decode64(parsed_json["encryptedData"])
    iv = decoded_data[0..15] # extracting the first 16 bytes as the iv
    data = decoded_data[16..(decoded_data.size - 1)] # extracting 16 bytes onwards as the actual data to be used
    decipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
    decipher.decrypt
    decipher.key = decrypted_key
    decipher.iv = iv
    actual_statement_json = decipher.update(data) # decrypting the actual data which should give us the un-parsed JSON of the statement
    actual_statement_json << decipher.final
    parsed_response = JSON.parse(actual_statement_json)
    return parsed_response
  end


  def post_process
    case self.response.status
      when 404
        self.parsed_response = {}
        add_message :error, "Service temporarily unavailable"
      when 500
        self.parsed_response = {}
        add_message :error, "Service temporarily unavailable"
      when 200
        if self.parsed_response["Response"] == "SUCCESS" || self.parsed_response["RESPONSE"]&.upcase == "SUCCESS"
          # parse the records and create the transactions in the IciciBankTransaction Model
          records = self.parsed_response["Record"]
          op = BankTransfer::Icici::Statement::Create.(self.company, records)
        else
          add_message :error, (self.parsed_response["MESSAGE"] || self.parsed_response["Message"])
        end
    end
  end

  def success?
    self.parsed_response["Response"]&.upcase == "SUCCESS" || self.parsed_response["RESPONSE"]&.upcase == "SUCCESS"
  end

  def failure?
    if self.parsed_response["Response"]&.upcase == "FAILURE" || self.parsed_response["RESPONSE"]&.upcase == "FAILURE"
      add_message :error, "Registration was not successful"
      return true
    end
    if self.parsed_response.blank?
      add_message :error, "The service is temporarily down. Try again later."
      return true
    end
  end

  def success
    IciciBankApi::AccountStatement::StatementSuccessPresenter.new(params, messages)
  end

  def failure
    IciciBankApi::AccountStatement::StatementFailurePresenter.new(params, messages)
  end

  class IciciBankApi::AccountStatement::StatementSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def initialize(params, messages)
      self.messages = messages
    end
  end

  class IciciBankApi::AccountStatement::StatementFailurePresenter < BaseOperation::BasePresenter::FailurePresenter


    def initialize(params, messages)
      self.messages = messages
    end
  end

end