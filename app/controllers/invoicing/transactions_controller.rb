class Invoicing::TransactionsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def index
    @result = Invoicing::Transactions::Index.(current_user, params)
    respond
  end

end