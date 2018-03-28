class Company::Signup < BaseOperation

  attr_accessor :signup_parameters, :signup_user

  def pre_validate
    if params.blank?
      messages[:error] << "Please fill up required fields (marked with *)"
    end

  end

  def init
    self.signup_parameters = signup_params
  end

  def pre_process
    # clean up the mobile number in case it has extra characters
    signup_parameters[:mobile_number] = CleanUpUtils.mobile_number_cleanup(signup_parameters[:mobile_number]) if signup_parameters[:mobile_number]
    signup_parameters[:products] = signup_parameters[:products].join(",")
  end

  def process
    self.signup_user = SignedupUser.new(signup_parameters)
    unless signup_user.save
      messages[:error] = signup_user.errors.full_messages
    end
  end

  def post_process
    messages[:success] = "You have successfully signed up"
    # trigger mailer acknowledging the preview request.

    # todo Mail to user who is singed up with welcome message
    # DemoMailer.delay.welcome_signedup_user(signup_user)
    Constants::PRODUCT_DEMO_EMAIL_ID.each do |recipient_email|
      DemoMailer.delay.signedup_user(signup_user, recipient_email)
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(nil, nil, messages)
  end

  private

  def signup_params
    params.require(:signup).permit(:name, :mobile_number, :email, :company_name, :password, :products => [])
  end
end
