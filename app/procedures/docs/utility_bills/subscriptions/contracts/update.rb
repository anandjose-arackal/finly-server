class Docs::UtilityBills::Subscriptions::Contracts::Update < Reform::Form

  property :id
  property :bbps_biller_id, presence: true
  property :name, presence: true
  property :sequence_id
  property :mobile_number, presence: true

  property :department_id
  property :cost_center_id
  property :location_id
  property :policy_id, presence: true

  property :note
  property :user_id, presence: true
  property :active

  property :agreement_id
  property :expected_due_day

  collection :subscription_pocs, populator: :subscription_pocs! do
    property :user_id
    property :subscription_id
  end

  # Virtual Properties
  property :current_user, virtual: true

  property :status_id, default: BbpsBillerSubscriptionStatus.id_for(:draft)

  collection :customer_fields, populator: :customer_fields! do
    property :subscription_id, presence: true
    property :label, presence: true
    property :value, presence: true
  end

  # collection :document_reviewer_mappings, virtual: true, populator: :document_reviewer_mappings! do
  #   property :level_id, presence: true
  #   property :reviewer_id
  # end

  # validates :expected_due_day inclusion: { in: (1..31).to_a,
  #                                             message: "%{value} is not a valid day" }

  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs
  validate :bbps_biller_params

  # validate :company_specific_entities

  def company_entities
    params = {filter_role_id: [UserRole.id_for(:utility_bill_master_initiator)], current_app: :vp}
    errors.add(:department_id, "Invalid Department") unless Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves&.pluck(:id)&.include?(department_id.to_i)
    errors.add(:cost_center_id, "Invalid Cost Center") unless current_user.company.cost_centers&.pluck(:id).include?(cost_center_id.to_i)
    errors.add(:location_id, "Invalid Location") unless Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves&.pluck(:id)&.include?(location_id.to_i)
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?

    if agreement_id.present?
      errors.add(:agreement_id, "Invalid Agreement Details") unless current_user.company.payment_agreements.find_by(id: agreement_id).present?
    end
  end

  # def related_entities
  #
  # end

  def bbps_biller_params
    op = Docs::UtilityBills::Billers::Ops::Show.({id: bbps_biller_id}, "current_user" => current_user)

    if op.success?
      bbps_biller = op['model']
      biller_customer_params = bbps_biller.biller_customer_params

      biller_customer_params.each do |biller_customer_param|

        label_name = biller_customer_param['param_name']

        customer_field = customer_fields.filter {|item| item.label == label_name}.first

        if biller_customer_param['data_type'].present?
          case biller_customer_param['data_type']
          when 'ALPHANUMERIC'
            return false unless check_alphanumeric(customer_field.value)
          end
        end

        if biller_customer_param['min_length'].present?
          return false unless customer_field.value&.to_s&.length >= biller_customer_param['min_length'].to_i
        end

        if biller_customer_param['max_length'].present?
          return false unless customer_field.value&.to_s&.length <= biller_customer_param['max_length'].to_i
        end

        if biller_customer_param['regex'].present?
          regex = Regexp.new biller_customer_param['regex']

          return false unless customer_field.value&.match(regex)
        end
      end
    end
  end

  private

  def check_alphanumeric(string)
    string.match(/\A[a-zA-Z0-9]*\z/)
  end

  def check_numeric(string)
    true
  end

  def customer_fields!(collection:, fragment:, index:, options:, **)
    customer_fields.insert(index, BbpsSubscriptionField.new)
  end

  def subscription_pocs!(collection:, fragment:, index:, options:, **)
    subscription_pocs.insert(index, BbpsSubscriptionPoc.new) if validate_or_assign_role(fragment)
  end

  def validate_or_assign_role(params)
    user_id = params[:user_id]
    pur = PolicyUserRole.find_or_initialize_by(user_id: user_id, policy_id: self.policy_id, user_role_id: UserRole.id_for(:utility_bill_initiator))
    pur.save
  end
end