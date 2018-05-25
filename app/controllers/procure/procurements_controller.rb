class Procure::ProcurementsController < ApplicationController
  before_action -> { finly_authorize! :web }

  def index
    @result = Procurements::Index.(current_user, params)
    respond
  end

  def show
    @result = Procurements::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::Create.(current_user, params)
    respond
  end
end