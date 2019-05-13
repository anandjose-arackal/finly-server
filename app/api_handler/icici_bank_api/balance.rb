class IciciBankApi::Balance < IciciBankApi::Base

  attr_accessor :balance, :params

  class IciciBankApi::Balance::BalanceSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance

    def init
      self.balance = params[:balance]
    end
  end

  class IciciBankApi::Balance::BalanceFailurePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balance

    def init
      self.balance = params[:balance]
    end
  end

  def initialize(company)
    self.company = company
    self.params = {}
  end

  def self.call(company)
    self.new(company).run
  end

  def env_key
    'icici_bank_balance_inquiry'
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not found"
      return
    end

    unless ["ICICI"].include?(self.company&.feature_subscription&.bank_service_provider&.upcase)
      add_message :error, "This corporate has not been configured with ICICI bank"
      return
    end
  end

  def raw_api_params
    {
        AGGRID: self.company_details["AGGR_ID"],
        CORPID: self.company_details["CORP_ID"],
        USERID: self.company_details["USER_ID"],
        URN: self.company.icici_bank_config.urn,
        ACCOUNTNO: self.company_details["DEBIT_ACC_NO"]
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
        self.balance = 0
        add_message :error, "This service does not exist"
      when 500
        self.balance = 0
        add_message :error, "Some internal error occurred"
      when 200
        self.balance = self.parsed_response["EFFECTIVEBAL"]
      else
        self.balance = 0
    end
  end

  def success?
    self.balance != 0 && self.response.status == 200
  end

  def failure?
    self.errors.present?
  end

  def success
    params[:balance] = self.balance
    IciciBankApi::Balance::BalanceSuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:balance] = self.balance
    IciciBankApi::Balance::BalanceFailurePresenter.new(user, params, messages)
  end


end