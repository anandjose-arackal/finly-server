class Invoicing::AnalyticsController < BaseControllers::WebBase

  # before_action :set_tokens_in_header, only: [:download]

  def index
    @result = Invoicing::Analytics::Index.(current_user, params)
    respond
  end

end
