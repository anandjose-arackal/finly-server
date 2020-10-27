class AnalyticsController < BaseControllers::WebBase
  layout 'trailblazers'

  def token
    endpoint AnalyticsDashboard::Ops::Config
  end

  def create
    endpoint AnalyticsDashboard::Ops::Create
  end

  def update
    endpoint AnalyticsDashboard::Ops::Update
  end

  def show
    endpoint AnalyticsDashboard::Ops::Show
  end

  def index
    endpoint AnalyticsDashboard::Ops::Index
  end

  def destroy
    endpoint AnalyticsDashboard::Ops::Destroy
  end

end
