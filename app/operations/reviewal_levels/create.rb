class ReviewalLevels::Create < ReviewalLevels::Base
  attr_accessor :reviewal_level_params, :reviewal_level, :policy

  # Sample Params
  # {
  #   reviewal_level: {
  #       policy_id: 1,
  #       associated_entity_type: 'PurchaseOrder'
  #
  #   }
  # }

  def init
    self.reviewal_level_params = reviewal_level_parameters

    # policies_op = Policy::Index.(current_user, params)
    self.policy = user.company.policies.find_by(id: reviewal_level_params[:policy_id])
    self.reviewal_level_params.delete(:policy_id)
  end

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
    end

    entity_types = %w( PurchaseOrderProvider InvoiceProvider ReportProvider MoneyRequestProvider TravelRequestProvider TravelRequestBookingProvider BankPaymentRequestProvider YesBankVendorProvider PurchaseRequestProvider PoInvoiceProvider NonPoInvoiceProvider PaymentAgreementProvider)
    # entity_types = WorkflowManager::Aasm::BaseProvider.providers

    unless entity_types.include?(reviewal_level_params[:associated_entity_type])
      add_message :error, 'Invalid Entity Type'
    end
  end

  def process
    highest_level = self.policy.levels.exclude_deleted
        .with_entity_type(reviewal_level_params[:associated_entity_type])
        .order(level_number: :desc).first

    level_number = 1

    if highest_level.present?
      level_number = highest_level.level_number + 1
    end

    self.reviewal_level = self.policy.levels.new(reviewal_level_params)
    self.reviewal_level.level_number = level_number
    if reviewal_level.valid?
      reviewal_level.save
    end
  end

  def post_process
    add_message :success, 'Successfully Created New Level'
  end

  private

  def reviewal_level_parameters
    params.require(:reviewal_level).permit(:policy_id, :associated_entity_type, :name)
  end
end