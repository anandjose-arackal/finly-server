class Company::Pricing < BaseOperation
  attr_accessor :pricing_parameters, :product_pricing_query

  def pre_validate
    if params.blank?
      messages[:error] << "Please fill up required fields (marked with *)"
    end

  end

  def init
    self.pricing_parameters = signup_params
  end

  def pre_process
    # clean up the mobile number in case it has extra characters
    pricing_parameters[:mobile_number] = CleanUpUtils.mobile_number_cleanup(pricing_parameters[:mobile_number]) if pricing_parameters[:mobile_number]
  end

  def process
    self.product_pricing_query = ProductPricingQuery.new(pricing_parameters)
    unless product_pricing_query.save
      messages[:error] = product_pricing_query.errors.full_messages
    end
  end

  def post_process
    messages[:success] = "Thank you for querying. Our representative will revert back to you shortly"
    # trigger mailer acknowledging the preview request.

    Constants::PRODUCT_DEMO_EMAIL_ID.each do |recipient_email|
      DemoMailer.delay.product_pricing_queries(product_pricing_query, recipient_email)
    end
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(nil, nil, messages)
  end

  private

  def signup_params
    params.require(:pricing).permit(:name, :mobile_number, :email, :employees, :accounting_system, :monthly_transactions, :monthly_invoices, :prepaid_cards, :product)
  end
end
