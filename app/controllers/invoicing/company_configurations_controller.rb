class Invoicing::CompanyConfigurationsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def update_credit_account
    @result = Company::Collect::CollectCreditAccount::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def update_collect_details
    @result = Company::Collect::CompanyDetails::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def update_collect_logo
    @result = Company::Collect::CompanyLogo::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def show_credit_account
    @result = Company::Collect::CollectCreditAccount::Show.(current_user, params)
    respond
  end

  def show_collect_details
    @result = Company::Collect::CompanyDetails::Show.(current_user, params)
    respond
  end


  def funds_auto_transfer_config
    @result = Invoicing::Company::FundsAutoTransferConfig::Show.(current_user, params)
    respond
  end

  def update_auto_transfer_config
    @result = Invoicing::Company::FundsAutoTransferConfig::Update.(current_user, params)
    respond
  end
  
end