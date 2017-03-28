# Expected params -> {report: {custom_fields: {1: 10, 2: 30}}} where custom_field is a hashmap with configuration_ids as keys
# Note: This operation will only create custom fields and set the values of custom fields but will not save the report.
## Primarily because the call class usually has a save call after this
class CustomField::SetReport < CustomField::Base
  attr_accessor :report, :field_configurations, :field_values, :reset

  def self.call(report, params= {})
    super(report, params)
  end

  def initialize(report, params= {})
    super(nil, params)
    self.report = report
  end

  def pre_validate
    if report.blank? or not report.kind_of?(Report)
      add_message :error, 'Report not found'
    end
  end

  def init

    # field_values = { "1": "abc", "2":"asdk"}
    self.field_values = {}
    if params.present? and params[:report].present? and params[:report][:custom_fields].present?
      self.field_values = params[:report][:custom_fields]
    end

    # Resetting will destroy all existing custom fields and create new ones for the report
    self.reset = false
    if params.present? and params.has_key?(:reset_fields)
      self.reset = params[:reset_fields]
    end

    # If reset is required, we need to fetch all the field_configurations for reports current policy
    return unless self.reset

    # If policy has been set, fetch all the custom fields from the policy, else retrieve it from organisation account
    policy = report.policy
    if policy.present?
      self.field_configurations = policy.field_configurations
    else
      self.field_configurations = report.user.company.field_configurations
    end

    # Retrieve configurations which are set only for reports
    if self.field_configurations.present?
      self.field_configurations = self.field_configurations.with_parent_type(FieldParentType.id_for(:report))
    end

  end

  def process

    # If reset has been set, destroy all custom fields and create new ones
    if self.reset
      report.custom_fields.destroy_all
    end

    required_ids = self.field_configurations.pluck(:id)
    existing_ids = self.report.custom_fields.pluck(:field_configuration_id)
    create_ids = required_ids - existing_ids

    if create_ids.present?
      self.field_configurations.with_id(create_ids).each do |config|
        # If value has not been set but default value is present, set the value as a deep clone of default value
        default_value = nil
        if config.default_value.present?
          default_value =config.default_value.deep_clone
        end
        report.custom_fields.build(field_configuration: config, value: default_value).save
      end
    end

    return if report.custom_fields.blank?

    report.custom_fields.each do |field|
      # Set values for fields but do not save. We can save everything in one go
      field.set_value(self.field_values[field.field_configuration_id], false) if self.field_values.has_key?(field.field_configuration_id)
    end


    # If report is saved by the class calling this operation, we do not have to save it here as it
    # would be getting saved there automatically
    if params.present? and params[:save]
      unless self.report.save
        add_message :error, self.report.errors.full_messages
      end
    end

  end

end