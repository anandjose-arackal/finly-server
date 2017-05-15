# currently uses one particular API for fetching, can be generalized to fetch from any particular endpoint
# the class that fetches the currency conversion data and sends it in the following format:
# date: "25-04-1991"
# INR: 52.36
# GBP: 1.000
# USD: 1.526
# .
# .
# .
# .

# Parameters being passed are:
# params:
#   date: "14-03-1998"
#   base: "GBP" - the base currency against which the rates are retrieved

class Currency::FetchData < BaseHandler

  attr_accessor :date, :base_currency, :request_path, :result_hash

  class Currency::FetchData::CurrencyDatPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :currency_data

    def init
      self.currency_data = params[:currency_data]
    end

  end

  def pre_validate
    if params.blank? || params[:date].blank?
      add_message :error, "Date cannot be blank"
    end
  end

  def env_key
    'currency_layer_currency_conversion'
  end

  def init
    super()
    self.date = params[:date]
    self.base_currency = params[:base]
    if base_currency.nil?
      self.base_currency = "GBP"
    end
    # appending the date to the path of the url
    self.request_path = self.path
  end

  def process
    self.response = self.connection.get do |req|
      req.url request_path
      req.params = {
         access_key: Constants::CURRENCY_LAYER_ACCESS_KEY,
         date: date
      }
    end
  end

  def parse
    # parsing the response body into a json string
    self.result_hash = extract_conversion_rates(JSON.parse(response.body))
  end

  def success
    params[:currency_data] = result_hash
    Currency::FetchData::CurrencyDatPresenter.new(user, params, messages)
  end

  private

  def extract_conversion_rates(parsed_json)
    result = {}
    parsed_json.each do |key, value|
      if key == 'quotes'
        value.each do |k, v|
          result[k[3..(k.size-1)]] = v
        end
      end
    end
    result
  end

end