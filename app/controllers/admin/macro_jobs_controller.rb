class Admin::MacroJobsController < BaseControllers::AdminBase
  layout 'trailblazers'

  def create
    endpoint Admin::Masters::Macros::Jobs::Create
  end

  def show
    endpoint Admin::Masters::Macros::Jobs::Show
  end

end
