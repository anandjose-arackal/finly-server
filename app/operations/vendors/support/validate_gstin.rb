class Vendors::Support::ValidateGstin < Vendors::Support::Base
  attr_accessor :gstin_params, :connection, :api_response, :response_body,
    :match_percentile, :valid_response, :gstin_master, :api_call_count

  class Vendors::Support::ValidateGstin::ValidatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :api_response, :match_percentile, :response_body, :match_percentile, :valid_response,
                  :gstin_master

    def init
      self.gstin_master = params[:gstin_master]
      self.response_body = params[:response_body]
      self.match_percentile = params[:match_percentile]
      self.valid_response = params[:valid_response]
      self.api_call_count = 1

    end
  end

  def init
    self.gstin_params = generate_params
    self.valid_response = false
    setup_connection
  end

  def validate
    if gstin_params[:gstin].blank? || !validate_gstin(gstin_params[:gstin])
      add_message :error, "Please provide a valid GSTIN"
    end
  end

  def process
    # Steps
    # 1. First search for GSTIN

    # First find in GSTIN Master
    self.gstin_master = Gstin.with_gstin(gstin_params[:gstin]).first

    unless gstin_master.present?
      if make_api_call
        self.response_body = self.gstin_master.api_response
        self.valid_response = true
        request_business_name = gstin_params[:business_name]
        response_business_name = gstin_master.legal_name_of_business

        if request_business_name.present? && response_business_name.present?
          self.match_percentile = StringUtils.fuzzy_string_match(request_business_name, response_business_name)
        end
      else
        add_message :error, "Something went wrong. Please try again later"
      end
    end
    #   # self.api_response = self.connection.get, { :gstin => gstin_params[:gstin] }
    #   self.api_response = self.connection.get

    #   if self.api_response.status && self.api_response.status == 200
    #     self.response_body = ActiveSupport::HashWithIndifferentAccess.new JSON.parse(self.api_response.body)
    #     if self.response_body[:error]
    #       add_message :error, "Something went wrong. Please try again later"
    #       return
    #     else
    #       # Save information to gstin master

    #       self.gstin_master = Gstin.create(gstin_master_params(response_body))

    #       self.valid_response = true

    #     end
    #   else
    #     add_message :error, "Something went wrong. Please try again later"
    #     return
    #   end
    # end   
  end

  def success
    params[:gstin_master] = self.gstin_master
    params[:valid_response] = self.valid_response
    params[:api_response] = self.api_response
    params[:response_body] = self.response_body
    params[:match_percentile] = self.match_percentile || 0
    Vendors::Support::ValidateGstin::ValidatePresenter.new(user, params, messages)
  end


  private

  def generate_params
    params.require(:gstin_location).permit(:gstin, :business_name)
  end

  def gstin_master_params(response_body)

    addr_array = response_body[:data][:pradr][:addr].values.reject {|i| i.empty?}

    data = {
      gstin: response_body[:data][:gstin],
      api_response: response_body,
      legal_name_of_business: response_body[:data][:lgnm],
      state: response_body[:data][:stj],
      date_of_registration: response_body[:data][:rgdt],
      constitution_of_business: response_body[:data][:ctb],
      status: response_body[:data][:sts],
      api_provider: response_body[:data][:masters_india],
      address: addr_array.join(", ")
    }

    data
  end

  def make_api_call
    setup_connection

    puts "Making GSTIN Search API Call"
    self.api_response = self.connection.get
    self.api_call_count += 1

    if self.api_response.status && self.api_response.status == 200
      self.response_body = ActiveSupport::HashWithIndifferentAccess.new JSON.parse(self.api_response.body)
      if self.response_body[:error]
        if (self.response_body[:error] == 'invalid_grant') && (self.api_call_count < 4) && authenticate
          make_api_call
        else       
          add_message :error, "Something went wrong. Please try again later"
          return
        end
      else
        # Save information to gstin master
        self.gstin_master = Gstin.create(gstin_master_params(response_body))
        self.valid_response = true
        return true
      end
    else
      add_message :error, "Something went wrong. Please try again later"
      return
    end
  end


  def authenticate
    path = "#{Rails.root}/config/gstin_verification_config.yml"
    config_data = ActiveSupport::HashWithIndifferentAccess.new YAML.load_file(path)[Rails.env]
    data = {}
    config_data[:authenticate][:params].each do |p|
      data[p.keys.first] = p.values.first
    end

    url = config_data[:base_url] + "/oauth/access_token"
    headers  config_data[:authentication][:headers]

    auth_connection = Faraday.new(url: url) do |req|
      req.adapter Faraday.default_adapter

      headers.each do |header|
        req.headers[header.keys.first] = header.values.first
      end
    end

    puts "Making GSTIN Authentication API Call"
    auth_response = auth_connection.post data

    # {
    #   "access_token": "0d08781040a8568c752a5cdbcdfba391bb10d679",
    #   "expires_in": 14400,
    #   "token_type": "bearer"
    # }

    if auth_response.status.present? && auth_response.status == 200
      auth_response_body = ActiveSupport::HashWithIndifferentAccess.new JSON.parse(auth_response.body)
      if auth_response_body.keys.include?("error")
        return false
      else
        access_token = auth_response_body[:access_token]

        if Rails.env.production? || Rails.env.staging?
          path = '/home/centos/app/shared/config/gstin_verification_config.yml'
        end

        d = YAML::load_file(path) #Load
        d['default']['search']['headers']['Authorizations'] = "Bearer #{access_token}"
        File.open(path, 'w') {|f| f.write d.to_yaml }
      end
      return true
    else
      return false
    end
  end

  def setup_connection
    path = "#{Rails.root}/config/gstin_verification_config.yml"
    config_data = ActiveSupport::HashWithIndifferentAccess.new YAML.load_file(path)[Rails.env]
    # url = config_data[:base_url] + '/searchgstin'
    url = config_data[:base_url] + "/commonapis/searchgstin?gstin=#{gstin_params[:gstin]}"
    headers = config_data[:search][:headers]
    self.connection = Faraday.new(url: url) do |req|
      # req.url = url
      req.adapter Faraday.default_adapter # make requests with Net::HTTP

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

# {
#     "error": false,
#     "data": {
#         "stjCd": "KA011",
#         "lgnm": "VV Finly Technology Private Limited",
#         "stj": "LVO 040 - BENGALURU",
#         "dty": "Regular",
#         "adadr": [],
#         "cxdt": "",
#         "gstin": "29AAGCV7942K1ZL",
#         "nba": [
#             "Supplier of Services"
#         ],
#         "lstupdt": "05/03/2019",
#         "rgdt": "05/03/2019",
#         "ctb": "Private Limited Company",
#         "pradr": {
#             "addr": {
#                 "bnm": "Wilson Court Apts",
#                 "st": "6th cross, 12th Main, Wilson Garden",
#                 "loc": "Bangalore",
#                 "bno": "S-204",
#                 "stcd": "Karnataka",
#                 "dst": "Bengaluru (Bangalore) Urban",
#                 "city": "",
#                 "flno": "",
#                 "lt": "",
#                 "pncd": "560027",
#                 "lg": ""
#             },
#             "ntr": "Supplier of Services"
#         },
#         "tradeNam": "VV Finly Technology Private Limited",
#         "ctjCd": "YV0205",
#         "sts": "Active",
#         "ctj": "RANGE-ESD2"
#     }
# }


#{
#     "error": true,
#     "data": "The GSTIN passed in the request is invalid."
# }

# {
#     "error": "invalid_grant",
#     "message": "The access token provided is invalid"
# }