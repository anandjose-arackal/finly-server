class IndexController < BaseControllers::WebBase
  layout 'trailblazers'

  def fetch_config
    endpoint IndexBuilder::Config
  end

  def index_view_config
    @index_config = endpoint IndexBuilder::Config
    @view_config = endpoint IndexSegment::Ops::Index
  end

  def show
    endpoint IndexBuilder::Show
  end

  def status_counts
    endpoint IndexBuilder::StatusCount
  end

  def record_counts
    endpoint IndexBuilder::RecordCount
  end

end
