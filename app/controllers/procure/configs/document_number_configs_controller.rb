class Procure::Configs::DocNumberConfigsController < ApplicationController

  def index

  end

  def update
    @result = Procurements::Configs::DocumentNumberConfigs::Update.(current_user, params)
    respond
  end

end