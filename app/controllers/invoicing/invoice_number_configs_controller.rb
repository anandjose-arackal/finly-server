class Invoicing::InvoiceNumberConfigsController < BaseControllers::PublicBase

  def update
    @result = Company::Collect::InvoiceNumberConfiguration::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Company::Collect::InvoiceNumberConfiguration::Show.(current_user, params)
    respond
  end

end
