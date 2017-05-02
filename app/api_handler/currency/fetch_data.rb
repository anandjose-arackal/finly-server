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
    'fixer_currency_conversion'
  end

  def init
    super()
    self.date = params[:date]
    self.base_currency = params[:base]
    if base_currency.nil?
      self.base_currency = "GBP"
    end
    # appending the date to the path of the url
    self.request_path = self.path + "/#{date}"
  end

  def process
    self.response = self.connection.get do |req|
      req.url request_path
      req.params = {
          base: base_currency
      }
    end
  end

  def parse
    # parsing the response body into a json string
    parsed_response = JSON.parse(response.body)
    self.result_hash = {
        date: date
    }
    parsed_response['rates'].each do |key, value|
      result_hash[key] = value
    end
  end

  def success
    params[:currency_data] = result_hash
    Currency::FetchData::CurrencyDatPresenter.new(user, params, messages)
  end

end