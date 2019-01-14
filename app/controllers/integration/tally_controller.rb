class Integration::TallyController < BaseControllers::WebBase

  before_action :set_tokens_in_header, only: [:vouchers, :reimbursements]
  before_action -> { finly_authorize! :web }

  def set_configuration
    @result = Integrations::Tally::SetConfiguration.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def vouchers
    @result = Integrations::Tally::Vouchers.(current_user, params)
    respond
  end

  def reimbursements
    @result = Integrations::Tally::Reimbursements.(current_user, params)
    respond
  end

  def check
    @result = Integrations::Tally::ValidateConfiguration.(current_user, params)
    respond
  end

end
