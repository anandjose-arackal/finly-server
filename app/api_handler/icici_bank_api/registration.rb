# this is a one time call, which will happen at the time of onboarding the client
class IciciBankApi::Registration < IciciBankApi::Base

  attr_accessor :company

  def init
    super
  end

  def initialize(company)
    self.company = company
    self.params = {}
  end

  def self.call(company)
    self.new(company).run
  end

  def icici_bank_action
    'icici_bank_registration'
  end

  def env_key
    'icici_bank_registration'
  end

  def raw_api_params
    {
        AGGRID: self.company_details["AGGR_ID"],
        AGGRNAME: self.company_details["AGGR_NAME"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        ALIASID: self.company.icici_bank_config.alias_id,
        URN: self.company.icici_bank_config.urn
    }
  end

  def post_params
    encrypt_params(
        raw_api_params
    )
  end


  def post_process
    case self.response.status
      when 404

      when 500

      when 200
        self.parsed_response = JSON.parse(self.decrypted_response)
    end
  end

  def success?
    self.parsed_response["Response"]&.upcase == "SUCCESS"
  end

  def failure?
    if self.parsed_response["Response"]&.upcase == "FAILURE"
      add_message :error, "Registration was not successful"
    end
  end

  def success
    IciciBankApi::Registration::RegistrationSuccessPresenter.new(params, messages)
  end

  def failure
    IciciBankApi::Registration::RegistrationFailurePresenter.new(params, messages)
  end

  class IciciBankApi::Registration::RegistrationSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end

  class IciciBankApi::Registration::RegistrationFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :transfer_request, :bank_transaction

    def initialize(params, messages)
      self.messages = messages
      self.transfer_request = params[:transfer_request]
      self.bank_transaction = params[:bank_transaction]
    end
  end


end