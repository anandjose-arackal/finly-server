class Admin::FiltersController  < BaseControllers::AdminBase
  layout 'trailblazers'

  def index
    endpoint ::Filters::Config
  end

end
