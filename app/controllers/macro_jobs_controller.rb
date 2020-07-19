class MacroJobsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint Macros::Run
  end

end
