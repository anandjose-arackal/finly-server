class ExportResourcesController < BaseControllers::WebBase
  layout 'trailblazers', only: [:index]

  def index
    endpoint Masters::ExportResources::Ops::Index
  end
end
