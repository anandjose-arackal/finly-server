class Invoicing::PaymentTermsController < BaseControllers::PublicBase

  def create
    @result = Invoicing::Company::PaymentTerms::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Invoicing::Company::PaymentTerms::Index.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::Company::PaymentTerms::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Invoicing::Company::PaymentTerms::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
