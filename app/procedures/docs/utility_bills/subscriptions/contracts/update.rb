class Docs::UtilityBills::Subscriptions::Contracts::Update < Reform::Form

  property :id
  property :bbps_biller_id, validates: {presence: true}
  property :name, validates: {presence: true}
  property :mobile_number, validates: {presence: true}

  property :department_id
  property :cost_center_id
  property :location_id
  property :policy_id, validates: {presence: true}

  property :category_id
  property :tax_rate_id
  property :hsn_sac

  property :note

  property :expected_bill_day
  property :reminder_before_days

  property :customer_name
  property :customer_email
  property :customer_pan
  property :customer_aadhar_number

  # collection :subscription_pocs, populator: :subscription_pocs! do
  collection :subscription_pocs, populate_if_empty: BbpsSubscriptionPoc do
    property :user_id, validates: {presence: true}
    property :subscription_id
    property :_destroy, virtual: true
  end

  # Virtual Properties
  property :current_user, virtual: true
  property :biller, virtual: true

  property :customer_param_key_1
  property :customer_param_value_1
  property :customer_param_key_2
  property :customer_param_value_2
  property :customer_param_key_3
  property :customer_param_value_3
  property :customer_param_key_4
  property :customer_param_value_4
  property :customer_param_key_5
  property :customer_param_value_5

  validate :company_entities # Checks for departments
  validate :validate_customer_params

  validate :poc_presence

  def poc_presence
    errors.add(:subscription_pocs, "You need to provide at least One POC") if subscription_pocs.blank?
  end


  def company_entities
    params = {filter_role_id: [UserRole.id_for(:utility_bill_master_initiator)], current_app: :vp}
    errors.add(:department_id, "Invalid Department") unless Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves&.pluck(:id)&.include?(department_id.to_i)
    errors.add(:cost_center_id, "Invalid Cost Center") unless current_user.company.cost_centers&.non_deleted&.pluck(:id).include?(cost_center_id.to_i)
    errors.add(:location_id, "Invalid Location") unless Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves&.pluck(:id)&.include?(location_id.to_i)
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?
  end


  def validate_customer_params
    valid = true
    op = Docs::UtilityBills::Billers::Ops::Show.(params: {id: bbps_biller_id}, "current_user" => current_user)

    if op.success?
      bbps_biller = op['model']
      biller_customer_params = bbps_biller.biller_customer_params

      5.times do |j|
        valid = validate_customer_field(biller_customer_params[j], self.send("customer_param_key_#{j + 1}"), self.send("customer_param_value_#{j + 1}"), j + 1)
      end
    end
    return valid
  end

  def validate_customer_field(config, label, value, a)
    valid = true
    if config.present?
      if label.present? && value.present?
        if config['param_name'] != label
          errors.add("customer_param_key_#{a}", "Expected Label #{config['param_name']}, got #{label}")
          valid = false
          return valid
        end
        case config['data_type']
        when 'ALPHANUMERIC'
          errors.add("customer_param_key_#{a}", 'Invalid Data Provided') unless check_alphanumeric(value)
          valid = false
        when 'NUMERIC'
          errors.add("customer_param_key_#{a}", "Please provide only numbers for #{label}") unless check_numeric(value)
          valid = false
        end

        if config['min_length'].present?
          errors.add("customer_param_key_#{a}", "#{label} should at least be of #{config['min_length']} characters") unless value&.to_s&.length >= config['min_length'].to_i
          valid = false
        end

        if config['max_length'].present?
          errors.add("customer_param_key_#{a}", "#{label} should not exceed #{config['max_length']} characters") unless value&.to_s&.length <= config['max_length'].to_i
          valid = false
        end

        if config['regex'].present?
          regex = Regexp.new config['regex']

          errors.add("customer_param_key_#{a}", "Please provide #{label} in the correct format") unless value&.match(regex)
          valid = false
        end
      else
        errors.add("customer_param_key_#{a}", "Please provide all the fields")
        valid = false
      end
    else
      if label.present? || value.present?
        errors.add("customer_param_key_#{a}", "Invalid details provided for #{label.present? ? label : value}")
        valid = false
      end
    end

    return valid
  end

  private

  def check_alphanumeric(string)
    string.match(/\A[a-zA-Z0-9]*\z/)
  end

  def check_numeric(string)
    string.match(/^\d+$/)
  end

  def customer_fields!(collection:, fragment:, index:, options:, **)
    customer_fields.insert(index, BbpsSubscriptionField.new)
  end

  def subscription_pocs!(collection:, fragment:, index:, options:, **)
    item = subscription_pocs.find {|subscription_poc| subscription_poc.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      subscription_pocs.destroy(item)
      return skip!
      # return Representable::Pipeline::Stop
    end

    validate_or_assign_role(fragment)

    item || subscription_pocs.append(BbpsSubscriptionPoc.new)
  end

  def validate_or_assign_role(params)
    user_id = params[:user_id]
    pur = PolicyUserRole.find_or_initialize_by(user_id: user_id, policy_id: self.policy_id, user_role_id: UserRole.id_for(:utility_bill_initiator))
    pur.save
  end
end