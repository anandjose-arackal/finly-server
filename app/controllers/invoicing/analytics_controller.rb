class Invoicing::AnalyticsController < BaseControllers::WebBase

  # before_action :set_tokens_in_header, only: [:download]
  before_action -> { finly_authorize! :web }

  def index
    @result = Invoicing::Analytics::Index.(current_user, params)
    respond
  end

end
