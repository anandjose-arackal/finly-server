class Procure::Configs::TermsController < ApplicationController
  before_action -> {finly_authorize! :web}
  def index
    @result = Procurements::Configs::Terms::Index.(current_user, params)
    respond
  end

  def show

  end

  def create
    @result = Procurements::Configs::Terms::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::Configs::Terms::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::Configs::Terms::Destroy.(current_user, params)
    respond
  end
end