class Admin::IndexViewSegmentsController < BaseControllers::AdminBase
  layout 'trailblazers'

  def index
    endpoint IndexSegment::Ops::Index
  end

end
