class Admin::MacroJobsController < BaseControllers::AdminBase

  def show
    endpoint Admin::Masters::Macros::Jobs::Show
  end

end
