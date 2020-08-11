class ExportTemplatesController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint Masters::ExportTemplates::Ops::Create
  end

  def index
    endpoint Masters::ExportTemplates::Ops::Index
  end

  def update
    endpoint Masters::ExportTemplates::Ops::Update
  end

  def show
    endpoint Masters::ExportTemplates::Ops::Show
  end
end
