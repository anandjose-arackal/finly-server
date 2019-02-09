class Procure::Configs::DocNumberConfigsController < BaseControllers::WebBase
  def index
    @result = Procurements::Configs::DocumentNumberConfigs::Index.(current_user, params)
    respond

  end

  def update
    @result = Procurements::Configs::DocumentNumberConfigs::Update.(current_user, params)
    respond
  end

end
