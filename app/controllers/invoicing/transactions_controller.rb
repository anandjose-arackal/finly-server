class Invoicing::TransactionsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def index
    @result = Invoicing::Transactions::Index.(current_user, params)

    result = [{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"}]
    render json: result.as_json
  end

end