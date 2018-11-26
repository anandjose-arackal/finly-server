# Expected params -> {report: {custom_fields: {1: 10, 2: 30}}} where custom_field is a hashmap with configuration_ids as keys
# Note: This operation will only create custom fields and set the values of custom fields but will not save the report.
## Primarily because the call class usually has a save call after this
class CustomField::SetFields < CustomField::Base
  attr_accessor :item, :field_configurations, :field_values, :reset, :save, :parent_type_id

  def self.call(item, parent_type_id, params = {})
    self.new(item, parent_type_id, params).run
  end

  def initialize(item, parent_type_id, params = {})
    super(nil, params)
    self.item = item
    self.parent_type_id = parent_type_id
  end

  def pre_validate
    if item.blank?
      add_message :error, 'Item not found'
      return
    end
    if parent_type_id.blank?
      add_message :error, 'Invalid Configuration'
      return
    end
    if FieldParentType.expense_ids.include?(parent_type_id) and item.expense.blank? and (params.blank? or params[:user].blank?)
      add_message :error, 'User not found'
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
    # if self.reset

    # If policy has been set, fetch all the custom fields from the policy, else retrieve it from organisation account
    if [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request),
        FieldParentType.id_for(:travel_request)].include?(parent_type_id) and item.policy.present?
      policy = item.policy
      self.field_configurations = policy.field_configurations.exclude_deleted
    elsif [FieldParentType.id_for(:booking_request)].include?(parent_type_id)
      policy = item.travel_request.policy
      self.field_configurations = policy.field_configurations.exclude_deleted
    else
      if [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request),
          FieldParentType.id_for(:purchase_order)].include?(parent_type_id)
        # For reports and money requests
        self.field_configurations = item.user.company.field_configurations.exclude_deleted
      elsif [FieldParentType.id_for(:invoice), FieldParentType.id_for(:outward_invoice), FieldParentType.id_for(:invoice_line_item), FieldParentType.id_for(:purchase_order)].include?(parent_type_id)
        self.field_configurations = current_company.field_configurations.exclude_deleted
      elsif FieldParentType.expense_ids.include?(parent_type_id)
        # For expenses
        user = item.expense.user rescue nil
        if user.blank?
          user = params[:user]
        end
        self.field_configurations = user.company.field_configurations.exclude_deleted
      end
    end

    # Retrieve configurations which are set only for items
    if self.field_configurations.present?
      self.field_configurations = self.field_configurations.exclude_deleted.with_parent_type(parent_type_id)
    end
    # end

    self.save = !!params&.dig(:save)
  end

  def process

    if self.reset
      # in this case we can reset the custom fields by destroying all existing custom fields and recreating them
      # from the field configurations set
      required_ids = self.field_configurations.pluck(:id)
      existing_ids = self.item.custom_fields.pluck(:field_configuration_id)
      configs_to_create, _ = process_custom_field_changes # because configs to create will be returned by the method that calculates what all need to be created
      config_ids_to_destroy = existing_ids - required_ids
    else
      configs_to_create, config_ids_to_destroy = process_custom_field_changes
    end


    configs_to_create.each do |config|
      default_value = nil
      if config.default_value.present?
        default_value = config.default_value.deep_clone
      end
      field = item.custom_fields.build(field_configuration: config, value: default_value)
      if self.save
        field.save
      end
    end

    item.custom_fields.with_field_configuration_ids(config_ids_to_destroy).destroy_all


    return if item.custom_fields.blank?

    item.custom_fields.each do |field|
      if self.field_values.has_key?(field.field_configuration_id)
        value = self.field_values[field.field_configuration_id]
        field.set_value(value, false)
      elsif self.field_values.has_key?(field.field_configuration_id.to_s)
        value = self.field_values[field.field_configuration_id.to_s]
        field.set_value(value, false)
      end
      # Set values for fields but do not save. We can save everything in one go
      # field.set_value(value, false) unless value.nil?
    end

    # If item is saved by the class calling this operation, we do not have to save it here as it
    # would be getting saved there automatically
    if self.save
      unless self.item.save
        add_message :error, self.item.errors.full_messages
      end
    end

  end

  # Once all acceptable values are identified in the previous step,
  # this step identifies the custom fields which have to be created / destroyed
  def process_custom_field_changes
    all_field_values = merged_custom_field_values
    acceptable_dropdown_values = identify_acceptable_dropdown_values all_field_values


    current_ids = self.item.custom_fields.pluck(:field_configuration_id)
    configs_to_create = []
    config_ids_to_destroy = []
    required_configs = {}

    self.field_configurations.enabled.each do |config|
      required = false
      if config.root_field
        # Root fields have to be present
        if FieldParentType.expense_ids.include?(parent_type_id)
          if current_ids.blank? or current_ids.include?(config.id)
            required = true
          end
        else
          required = true
        end
      else
        acceptable_dropdown_values.each do |value|
          # If the custom field configuration is a dropdown and
          # the value matches the dependent field configuration criteria, add it to required custom fields
          if config.parent_drop_down_items.pluck(:id).include?(value.to_i)
            # if current_ids.blank? or not current_ids.include?(config.id)
            required = true
            # end
          end
        end
      end


      required_configs[config.id] = config if required
    end

    config_ids_to_destroy = current_ids - required_configs.keys

    required_configs.each do |id, config|
      unless current_ids.include?(id)
        configs_to_create << config
      end
    end

    [configs_to_create, config_ids_to_destroy]
  end

  # As mobile apps send only the updated data, we need to create a hash
  # which contains the previous values as well as the new changed values
  # to determine which call dependent custom fields are required
  def merged_custom_field_values
    all_field_values = self.field_values.clone
    self.item.custom_fields.drop_down_custom_fields_only.each do |cf|
      if all_field_values[cf.field_configuration_id.to_s].nil? and not cf.value.nil?
        all_field_values[cf.field_configuration_id.to_s] = cf.value.value_id.to_s
      end
    end
    all_field_values
  end

  # Identify all the relevant custom fields based on the selected values.
  # First loop runs through the root field to add all the values as acceptable values
  # Second loop identifies the dependent custom field from the roots selected values
  # Third and all other loops keep identifying more and more dependent custom fields
  # based on the previously identified acceptable values
  def identify_acceptable_dropdown_values(all_field_values)
    acceptable_dropdown_values = []
    dropdown_field_ids = self.field_configurations.enabled.filter_dropdowns.pluck(:id)
    completed = false
    until completed
      completed = true
      self.field_configurations.each do |config|
        next unless config.enabled
        next unless dropdown_field_ids.include?(config.id)
        acceptable_value = false
        if config.root_field
          # If root field, add the value to acceptable dropdown values
          acceptable_value = true
        else
          if acceptable_dropdown_values.any? {|drop_down_value| config.parent_drop_down_items.pluck(:id).include?(drop_down_value)}
            # if acceptable_dropdown_values.include?(config.parent_id.to_s)
            acceptable_value = true
          end
        end
        if acceptable_value and not acceptable_dropdown_values.include?(all_field_values[config.id.to_s])
          acceptable_dropdown_values << all_field_values[config.id.to_s]
          completed = false
        end
      end
    end
    acceptable_dropdown_values
  end

end