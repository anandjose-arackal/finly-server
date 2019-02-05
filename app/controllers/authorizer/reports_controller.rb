class Authorizer::ReportsController < ApplicationController
  def show
    @result = Reports::ReportAuthorizer::Show.(params)
    if @result.failure?
      respond response: :failure
      return
    end
  end

  def approve
    @result = Reports::ReportAuthorizer::Approve.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond render: :show
  end

  def reject
    @result = Reports::ReportAuthorizer::Reject.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond render: :show
  end
end