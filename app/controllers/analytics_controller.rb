class AnalyticsController < ApplicationController

  def show
    @result = Analytics::Charts.(current_user, params)
    unless @result.success?
      @result.charts = {}
    end
    # debugger
    respond
  end

end
