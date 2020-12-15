class ExportFormatsController < BaseControllers::WebBase
  layout 'trailblazers', only: [:index]

  def index
    endpoint Masters::ExportFormats::Ops::Index
  end
end
