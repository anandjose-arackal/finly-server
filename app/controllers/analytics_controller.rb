class AnalyticsController < ApplicationController
  before_action :doorkeeper_authorize!

  def show
    # params[:page] = 1
    @result = Analytics::Charts.(current_user, params)
    unless @result.success?
      @result.charts = {}
    end
    respond
  end

end
