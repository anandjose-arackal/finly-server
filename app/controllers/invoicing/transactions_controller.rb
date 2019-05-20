class Invoicing::TransactionsController < BaseControllers::WebBase


  def index
    @result = Invoicing::Transactions::Index.(current_user, params)
    respond
    # result = [{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"},{"source_account":{"name":"Account 1","ifsc":"IFSC00001111","account_number":"000011113333334444"},"amount":1,"note":"Some note","date":"2018-01-16"}]
    # render json: result.as_json
  end

  def count
    @result = Invoicing::Transactions::Count.(current_user, params)
    render json: @result.count.as_json
  end

end
