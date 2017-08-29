class Authorizer::AgreementsController < ApplicationController
  def index
    @result = Agreements::AgreementAuthorizer::Index.(params)
    if @result.failure?
      respond response: :failure
      return
    end
  end

  def agree
    @result = Agreements::AgreementAuthorizer::Agree.(params)
    if @result.failure?
      respond response: :failure
      return
    end
    respond response: :success
  end
end