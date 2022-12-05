class ImportJobsController < BaseControllers::WebBase
  layout 'trailblazers'

  def index
    endpoint ImportJobs::Ops::Index
  end

  def template
    endpoint ImportJobs::Ops::Template
  end

  def create
    endpoint ImportJobs::Ops::Create
  end

  def show
    endpoint ImportJobs::Ops::Show
  end

  def records
    endpoint ImportJobs::Records::Ops::Index
  end

  def record_show
    endpoint ImportJobs::Records::Ops::Show
  end

  def record_update
    endpoint ImportJobs::Records::Ops::Update
  end

  def submit
    endpoint ImportJobs::Ops::Submit
  end

  def add_attachment
    endpoint ImportJobs::Attachments::Ops::Create
  end

  def delete_attachment
    endpoint ImportJobs::Attachments::Ops::Delete
  end
end
