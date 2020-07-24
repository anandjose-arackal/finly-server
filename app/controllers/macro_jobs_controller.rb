class MacroJobsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint Macros::Jobs::Create
  end

end
