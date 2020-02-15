class IndexViewSegmentsController < BaseControllers::WebBase
  layout 'trailblazers'

  def create
    endpoint IndexSegment::Ops::Create
  end

  def update
    endpoint IndexSegment::Ops::Update
  end

  def index
    endpoint IndexSegment::Ops::Index
  end

  def destroy
    endpoint IndexSegment::Ops::Destroy
  end
end
