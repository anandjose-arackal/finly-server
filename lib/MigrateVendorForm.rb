
# Checklist:
# [] Change Company ID Below & Deploy
# [] Vendor Form is seeded for the company
# [] Custom Fields are added for Vendor

class MigrateVendorForm
  def self.perform(company_id)
  
    form = Form.where(company_id: company_id, model: 'YesBankVendor').first

    entity = form.entities.where(entity_key: 'vendor_country')

    params = {
      company_id: company_id,
      form_id: entity.form.uuid,
      form_section_id: entity.form_section_id,
      entity_key: entity.entity_key,
      label: entity.label,
      placeholder: entity.placeholder,
      hint: entity.hint,
      entity_type: entity.entity_type,
      default_value: entity.default_value,
      editable: entity.editable,
      required: entity.required,
      active: entity.active,
      unique: entity.unique,
      visible: entity.visible,
      position: entity.position,
      system_field: entity.system_field,
      can_visible_be_changed: entity.can_visible_be_changed,
      can_editable_be_changed: entity.can_editable_be_changed,
      can_required_be_changed: entity.can_required_be_changed,
      can_uniqueness_be_changed: entity.can_uniqueness_be_changed,
      can_be_disabled: entity.can_be_disabled,
      can_label_be_renamed: entity.can_label_be_renamed,
      can_choices_be_changed: entity.can_choices_be_changed,
      allow_clearing_default_value: entity.allow_clearing_default_value,
      options: {},
      data_provider: entity.data_provider,
      choices_scope: nil,
      internal: entity.internal,
      is_modified: entity.is_modified,
      entity_path: 'vendor_country_id',
      parent_id: entity.parent_id,
      populate_if_empty: entity.populate_if_empty,
      config: {},
      associate_custom_fields: entity.associate_custom_fields,
      compute_enabled: entity.compute_enabled,
      compute_type_id: entity.compute_type_id,
      compute_lookup_entity_id: entity.compute_lookup_entity_id,
      compute_formula: entity.compute_formula,
      filters: entity.filters,
      config_path: "vendor_details.entities.vendor_country_id",
      compute_lookup_assignments: entity.compute_lookup_assignments,
    }

    FormEntity::Lookup.new(params).save

    condition_ids = [ "Disable Locations(GSTIN) for International Vendors", "Disabled State ID for International Vendor", "Disable GST Registerd for International Vendors", "Enable Tax Residency Certificate Attachment for International Vendors", "Enable Form 10F Attachment for International Vendors", "Enable No PE Attachment for International Vendors", "Disable PAN for International Vendors", "Hide PAN Attachment for International Vendors", "Disable RCM Enabled for International Vendors", "Enable Tax Rates for International Vendors", "Disable TDS Rate for International Vendors", "Disable TDS Effective Start Date for International Vendors", "Disable TDS Effective End Date for International Vendors", "Disable MSME Registered for International Vendors", "Disable MSME Registration Number for International Vendors", "Disable MSME Attachment for International Vendors", "Disable LDC for International Vendors", "Disable LDC Start Date for International Vendors", "Disable LDC End Date for International Vendors", "Disable Lower Exemption Certificate Attachment for International Vendors", "Disable Tax Exemption Certificate for International Vendors", "Disable Locations > GSTIN for International Vendors", "Disable Locations > GST Status for International Vendors", "Disable Locations > GSTIN Certificate for International Vendors", "Enable Bank Accounts > Swift / BIC Code for International Vendors", "Disable Bank Accounts > IFSC Code for International Vendors"  ]
    conditions = form.conditions.where(condition_id: condition_ids)
    rule = Rules::Builder[:vendor_country_id].not_eq(*Country.ids_for('India').map {|item| {value: item}})
    conditions.update_all(rule:  rule)

  end
end
