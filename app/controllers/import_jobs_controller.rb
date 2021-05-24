class ImportJobsController < BaseControllers::WebBase
  layout 'trailblazers'

  def index
    endpoint ImportJobs::Ops::Index
  end
end
