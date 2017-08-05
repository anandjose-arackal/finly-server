class AnalyticsController < ApplicationController
  before_action -> { finly_authorize! :web}

  def show
    # params[:page] = 1
    @result = Analytics::Charts.(current_user, params)
    unless @result.success?
      @result.charts = {}
    end
    respond
  end

end
