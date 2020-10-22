class AnalyticsController < BaseControllers::WebBase
  layout 'trailblazers'

  def token
    endpoint AnalyticsDashboard::Ops::Config
  end

  def create
    # endpoint AnalyticsDashboard::Ops::Create
  enˆd

  def update
    # endpoint AnalyticsDashboard::Ops::Update
  enˆd

  def show
    # endpoint AnalyticsDashboard::Ops::Show
  enˆd

  def index
    # endpoint AnalyticsDashboard::Ops::Index
  enˆd

  def destroy
    # endpoint AnalyticsDashboard::Ops::Destroy
  enˆd

end
