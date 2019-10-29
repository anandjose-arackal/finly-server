class Docs::UtilityBills::Subscriptions::Contracts::Base < Reform::Form

  property :id
  property :bbps_biller_id, presence: true
  property :name, presence: true
  property :sequence_id

  property :department_id
  property :cost_center_id
  property :location_id
  property :policy_id

  property :note
  property :user_id, presence: true
  property :active


  # Virtual Properties
  property :current_user, virtual: true


  property :status_id, default: BbpsBillerSubscriptionStatus.id_for(:draft)

  collection :customer_fields, populator: :customer_fields! do
    property :subscription_id, presence: true
    property :label, presence: true
    property :value, presence: true
  end

  validate :bbps_biller

  def bbps_biller
    op = Docs::UtilityBills::Billers::Ops::Show.({id: bbps_biller_id}, "current_user" => current_user)

    if op.success?
      bbps_biller = op['model']
      biller_customer_params = bbps_biller.biller_customer_params

      biller_customer_params.each do |biller_customer_param|

        label_name = biller_customer_param['param_name']

        customer_field = customer_fields.filter{|item| item.label == label_name}.first

        if biller_customer_param['data_type'].present?
          case biller_customer_param['data_type']
          when 'ALPHANUMERIC'
            debugger
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

  def customer_fields!(collection:, fragment:, index:, **)
    customer_fields.insert(index, BbpsSubscriptionField.new)
  end
end