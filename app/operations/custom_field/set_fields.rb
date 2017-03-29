# Expected params -> {report: {custom_fields: {1: 10, 2: 30}}} where custom_field is a hashmap with configuration_ids as keys
# Note: This operation will only create custom fields and set the values of custom fields but will not save the report.
## Primarily because the call class usually has a save call after this
class CustomField::SetFields < CustomField::Base
  attr_accessor :item, :field_configurations, :field_values, :reset, :save, :parent_type_id

  def self.call(item, parent_type_id, params= {})
    self.new(item, parent_type_id, params).run
  end

  def initialize(item, parent_type_id, params= {})
    super(nil, params)
    self.item = item
    self.parent_type_id = parent_type_id
  end

  def pre_validate
    if item.blank?
      add_message :error, 'Item not found'
    end
  end

  def init

    # field_values = { "1": "abc", "2":"asdk"}
    self.field_values = {}
    if params.present? and params[:custom_fields].present?
      self.field_values = params[:custom_fields]
    end

    # Resetting will destroy all existing custom fields and create new ones for the item
    self.reset = false
    if params.present? and params.has_key?(:reset_fields)
      self.reset = params[:reset_fields]
    end

    # If reset is required, we need to fetch all the field_configurations for item's current policy
    if self.reset

      # If policy has been set, fetch all the custom fields from the policy, else retrieve it from organisation account
      if [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request)].include?(parent_type_id) and item.policy.present?
        policy = item.policy
        self.field_configurations = policy.field_configurations
      else
        if [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request)].include?(parent_type_id)
          # For reports and money requests
          self.field_configurations = item.user.company.field_configurations
        elsif FieldParentType.expense_ids.include?(parent_type_id)
          # For expenses
          self.field_configurations = item.expense.user.company.field_configurations
        end

      end

      # Retrieve configurations which are set only for items
      if self.field_configurations.present?
        self.field_configurations = self.field_configurations.with_parent_type(parent_type_id)
      end
    end

    self.save = false
    if params.present? and params.has_key?(:save)
      self.save = params[:save]
    end

  end

  def process

    # If reset has been set, destroy all custom fields and create new ones
    if self.reset
      item.custom_fields.destroy_all

      required_ids = self.field_configurations.pluck(:id)
      existing_ids = self.item.custom_fields.pluck(:field_configuration_id)
      create_ids = required_ids - existing_ids

      if create_ids.present?
        self.field_configurations.enabled.with_id(create_ids).each do |config|
          # If value has not been set but default value is present, set the value as a deep clone of default value
          default_value = nil
          if config.default_value.present?
            default_value =config.default_value.deep_clone
          end
          item.custom_fields.build(field_configuration: config, value: default_value).save
        end
      end
    end

    return if item.custom_fields.blank?

    item.custom_fields.each do |field|
      value = nil
      if self.field_values.has_key?(field.field_configuration_id)
        value = self.field_values[field.field_configuration_id]
      elsif self.field_values.has_key?(field.field_configuration_id.to_s)
        value = self.field_values[field.field_configuration_id.to_s]
      end
      # Set values for fields but do not save. We can save everything in one go
      field.set_value(value, false) if value.present?
    end

    # If item is saved by the class calling this operation, we do not have to save it here as it
    # would be getting saved there automatically
    if self.save
      unless self.item.save
        add_message :error, self.item.errors.full_messages
      end
    end

  end

end