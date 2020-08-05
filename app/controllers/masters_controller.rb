class MastersController < BaseControllers::WebBase

  def index
    endpoint Masters::Schema::Ops::Index
  end

  def show
    endpoint Masters::Schema::Ops::Show
  end

end
