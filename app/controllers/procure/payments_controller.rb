class Procure::PaymentsController < ApplicationController
  before_action -> {finly_authorize! :web}

  def show
    @result = Procurements::Payments::Show.(current_user, params)
    respond
  end
end