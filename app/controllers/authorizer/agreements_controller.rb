class Authorizer::AgreementsController < ApplicationController
  def index
    @result = Report::ReportAuthorizer::Show.(params)
    if @result.failure?
      respond response: :failure
      return
    end
  end

  def agree
    @result = Report::ReportAuthorizer::Approve.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond render: :show
  end


end