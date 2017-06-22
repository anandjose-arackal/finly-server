class Authorizer::ReportsController < ApplicationController
  def show
    @result = Report::ReportAuthorizer::Show.(params)
    # debugger
    if @result.failure?
      respond response: :failure
      return
    end
  end

  def approve
    @result = Report::ReportAuthorizer::Approve.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond render: :show
  end

  def reject
    @result = Report::ReportAuthorizer::Reject.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond render: :show
  end
end