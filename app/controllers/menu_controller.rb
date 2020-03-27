class MenuController < BaseControllers::WebBase
  layout 'trailblazers'

  def show
    endpoint Menu::Processor
  end

end
