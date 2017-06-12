class Company::Preview < BaseOperation

  attr_accessor :preview_company, :preview_parameters

  def pre_validate
    if params.blank?
      messages[:error] << "Please fill up required fields (marked with *)"
    end
  end

  def init
    self.preview_parameters = preview_params
  end

  def pre_process
    # clean up the mobile number in case it has extra characters
    preview_parameters[:phone_number] = CleanUpUtils.mobile_number_cleanup(preview_parameters[:phone_number]) if preview_parameters[:phone_number]
  end

  def process
    self.preview_company = PreviewRegistration.new(preview_parameters)
    unless preview_company.save
      messages[:error] = preview_company.errors.full_messages
    end
  end

  def post_process
    messages[:success] = "Thank you for the request! We will contact you soon"
    # trigger mailer acknowledging the preview request.
    DemoMailer.delay.preview_welcome(preview_company)
    Constants::PRODUCT_DEMO_EMAIL_ID.each do |recipient_email|
      DemoMailer.delay.notify_preview(preview_company, recipient_email)
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(nil, nil, messages)
  end

  private

  def preview_params
    params.require(:preview).permit(:name, :phone_number, :email, :company, :source, :source_description)
  end
end
