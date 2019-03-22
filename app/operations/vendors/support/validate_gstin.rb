class Vendors::Support::ValidateGstin < Vendors::Support::Base
  attr_accessor :gstin_params, :connection, :api_response

  class Vendors::Support::ValidateGstin::ValidatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :api_response, :match_percentile

    def init
      self.api_response = params[:api_response]
    end
  end

  def init
    self.gstin_params = generate_params
    setup_connection
  end

  def validate
    if gstin_params[:gstin].blank? || !validate_gstin(bank_account_params[:account_number])
      add_message :error, "Please provide a valid GSTIN"
    end
  end


  def process
    self.api_response = self.connection.get '/searchgstin', { :gstin => gstin_params[:gstin] }

    self.api_response = self.api_response.as_json
  end

  def success
    params[:api_response] = self.api_response
    Vendors::Support::ValidateGstin::ValidatePresenter.new(user, params, messages)
  end


  private

  def generate_params
    params.require(:gstin_location).permit(:gstin, :business_name)
  end

  def setup_connection
    path = "#{Rails.root}/config/gstin_verification_config.yml"
    config_data = ActiveSupport::HashWithIndifferentAccess.new YAML.load_file(path)[Rails.env]
    url = config_data[:base_url]
    headers = 
    self.connection = Faraday.new do |req|
      req.url = url

      headers.each do |header|
        req.headers[header.keys.first] = header.values.first
      end
    end
  end

  def validate_gstin(item)
    pattern = Regexp.new(Constants::VALID_GSTIN)
    if item =~ pattern
      return true
    else
      return false
    end
  end
end

# {"error":false,"data":"{"rgdt":"01/07/2017","ctb":"Public Limited
# Company","sts":"Active","lgnm":"Masters TN TaxPayer 2
# Ltd","stj":"ADYAR","ctj":"ALLAHABAD-
# I","dty":"Regular","cxdt":"","gstin":"12GSPTN0507G1Z3"}"}