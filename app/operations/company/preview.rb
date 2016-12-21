class Company::Preview < BaseOperation

  attr_accessor :preview_company

  def pre_validate
    if params.blank?
      messages[:error] << "Please fill up required fields (marked with *)"
    end
  end

  def process
    self.preview_company = PreviewRegistration.new(preview_params)
    unless preview_company.save
      messages[:error] = preview_company.errors.full_messages
    end
  end

  def post_process
    messages[:success] = "Thank you for the request! We will contact you soon"
    # trigger mailer acknowledging the preview request.
    DemoMailer.delay.preview_welcome(preview_company)
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(nil, nil, messages)
  end

  private

  def preview_params
    params.require(:preview).permit(:name, :phone_number, :email, :company)
  end


end
