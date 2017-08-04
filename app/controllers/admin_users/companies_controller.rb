class AdminUsers::CompaniesController < ApplicationController

  # todo - temporary

  before_action -> { finly_authorize! :admin }

  def new
    @states = State.all
  end

  def show
    @result = Admin::Companies::Show.(current_user, params)
    respond
  end

  def create
    @result = Admin::Companies::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Admin::Companies::Index.(current_user, params)
    respond
  end

  def update
    @result = Admin::Companies::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def check_dcode
    @result = Admin::Companies::VerifyDcodeActivation.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def configure_payu
    @result = Admin::Companies::ConfigurePayu.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def company_types
    @company_types = CompanyType.all
  end

  private


end
