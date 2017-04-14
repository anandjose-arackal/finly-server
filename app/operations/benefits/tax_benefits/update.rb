# Create is used to create the required payment order and prepare for execution.
# If the order is scheduled, it schedules the payment_order,
# or else it calls the Benefits::TaxBenefits::Execute in background to execute the payment order
class Benefits::TaxBenefits::Update < Benefits::TaxBenefits::Base
  attr_accessor :response_presenter

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading request'
      return
    end
  end

  def process
    order_data = params[:payment_order]
    self.response_presenter = Benefits::TaxBenefits::Process.(config, user, payment_order: order_data, card_program_id: card_program_id)
    unless self.response_presenter.success?
      add_message :error, self.response_presenter.messages[:error]
    end
  end

  def success
    self.response_presenter
  end

end
