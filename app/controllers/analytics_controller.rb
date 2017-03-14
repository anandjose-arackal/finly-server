class AnalyticsController < ApplicationController
  allow_oauth!

  def show
    # params[:page] = 1
    @result = Analytics::Charts.(current_user, params)
    unless @result.success?
      @result.charts = {}
    end
    respond
  end

end
