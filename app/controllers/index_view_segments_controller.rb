class IndexViewSegmentsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint IndexSegment::Ops::Create
  end

  def update
  end

  def index
    endpoint IndexSegment::Ops::Index
  end

  def destroy
  end
end
