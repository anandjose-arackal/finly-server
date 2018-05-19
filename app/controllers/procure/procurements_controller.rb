class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def create
    @result = Procurements::Create.(current_user, params)
    respond
  end
end