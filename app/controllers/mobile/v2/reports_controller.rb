class Mobile::V2::ReportsController < ApplicationController

  def show
    @result = Report::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end
