class IndexController < BaseControllers::WebBase
  layout 'trailblazers'

  def fetch_config
    endpoint IndexBuilder::Config
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
