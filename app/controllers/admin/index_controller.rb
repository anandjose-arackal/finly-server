class Admin::IndexController < BaseControllers::AdminBase
  layout 'trailblazers'

  def fetch_config
    endpoint Admin::Index::Config
  end

  def show
    endpoint Admin::Index::Show
  end

  def status_counts
    endpoint Admin::Index::StatusCount
  end

  def record_counts
    endpoint Admin::Index::RecordCount
  end

end
