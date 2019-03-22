class Vendors::Support::ValidateGstin < Vendors::Support::Base
  attr_accessor :gstin_params, :connection, :api_response

  def init
    self.gstin_params = generate_params
    configure_connection
  end


  def process
    response = Faraday.get "#{root_url}api/privacy"
    @agreement = JSON.parse response.body

    self.api_response = self.connection.get    
  end


  private

  def generate_params
    params.require(:gstin_location).permit(:gstin, :business_name)
  end

  def setup_connection
    path = "#{Rails.root}/config/gstin_verification_config.yml"
    values = YAML.load_file(path)
    config_data = YAML.load_file('config/gstin_verification_config.yml')[Rails.env]
    url = Constants::GstinProvider::BASE_API
    headers = Constants::GstinProvider::HEADERS
    self.connection = Faraday.new do |req|
      req.url = url

      headers.each do |header|
        req.headers[header[:key]] = header[:value]
      end
    end

    res = con.get do |req| 
      req.url 'http://localhost:4567/agent' 
      req.headers['User-Agent'] = 'Ruby script'
    end
  end
end

# {"error":false,"data":"{"rgdt":"01/07/2017","ctb":"Public Limited
# Company","sts":"Active","lgnm":"Masters TN TaxPayer 2
# Ltd","stj":"ADYAR","ctj":"ALLAHABAD-
# I","dty":"Regular","cxdt":"","gstin":"12GSPTN0507G1Z3"}"}