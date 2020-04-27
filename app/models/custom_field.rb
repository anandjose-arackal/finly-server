# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  parent_id              :integer
#  parent_type            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_id               :integer
#  value_type             :string(255)
#  dependent_parent_id    :integer
#  dependent_parent_type  :string(255)
#  field_key              :string(255)
#  configured_field_value :text(65535)
#  deleted_at             :datetime
#

class CustomField < ApplicationRecord
  belongs_to :field_configuration, optional: true
  belongs_to :parent, optional: true, polymorphic: true

  # If the custom field is destroyed, destroyed its associated value
  belongs_to :value, optional: true, polymorphic: true, dependent: :destroy

  accepts_nested_attributes_for :value

  ransacker :value_search, args: [:parent, :ransacker_args] do |parent, args|
    field_configuration_id = 0
    if args&.is_a?(Hash) and args[:custom_field_id].present?
      field_configuration_id = args[:custom_field_id]
    end
    # Note that Arel::Nodes::InfixOperation requires the fields to be from parent.table or of type Arel::Nodes.build_quoted
    # Arel::Nodes::InfixOperation.new(
    #     'AND',
    #     Arel::Nodes::InfixOperation.new("=", parent.table[:field_configuration_id], Arel::Nodes.build_quoted(field_configuration_id)),
    #     parent.table[:configured_field_value]
    # )

    # This performs the same as above, easier to read
    Arel.sql("`custom_fields`.`field_configuration_id` = #{field_configuration_id} AND `custom_fields`.`configured_field_value`")
  end

  # validate :validate_field

  validates :field_configuration_id, presence: true
  validates :parent_type, :inclusion => {:in => ['ManualExpense', 'CardExpense', 'TimeExpense', 'PerDiemExpense', 'DistanceExpense', 'Report', 'MoneyRequest', 'Invoice', 'InvoiceLineItem', 'PurchaseOrder', 'TravelRequest', 'Booking', 'YesBankVendor', 'PurchaseRequest', 'PurchaseRequestItem', 'GeneralInvoice', 'RentalInvoice', 'Item', 'PaymentAgreement', 'RateContract']}
  validates :value_type, :inclusion => {:in => [nil, 'FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText', 'FieldMultiselectSelection']}

  scope :only_drop_downs, -> { where value_type: 'FieldDropDownSelection' }
  scope :with_field_configuration_ids, ->(ids) { where field_configuration_id: ids }
  scope :includes_parent, -> { includes :parent }
  scope :expenses, -> { where parent_type: ['ManualExpense', 'CardExpense', 'TimeExpense', 'PerDiemExpense', 'DistanceExpense'] }
  scope :with_parent_report, -> { where parent_type: ['Report'] }
  scope :with_drop_down_selection, -> (drop_down_selection_id) { where value_type: 'FieldDropDownSelection', value_id: drop_down_selection_id }
  scope :with_text_value, -> (text) {
    text_value_ids = FieldText.where('value like ?', "%#{text}%")
    where(value_type: "FieldText", value_id: text_value_ids)
  }
  scope :with_parent, -> (parent_id, parent_type) { where parent_id: parent_id, parent_type: parent_type }
  scope :with_multi_select_selection, -> (multiselect_selection_id) {
    multi_select_ids = self.where(value_type: "FieldMultiselectSelection").pluck(:value_id)
    multi_select_ids = FieldMultiselectSelectionItem.with_value(multiselect_selection_id).with_field_multiselect_selection(multi_select_ids).pluck(:field_multiselect_selection_id)
    ids = CustomField.where(value_id: multi_select_ids, value_type: "FieldMultiselectSelection").pluck(:id)
    where(id: ids)
  }
  scope :with_root_field_configurations, -> {
    field_config_ids = self.pluck(:field_configuration_id)
    root_field_config_ids = FieldConfiguration.where(id: field_config_ids, root_field: true).pluck(:id)
    where(field_configuration_id: root_field_config_ids)
  }

  scope :only_non_root_field_configs, -> {
    field_config_ids = self.pluck(:field_configuration_id)
    non_root_field_config_ids = FieldConfiguration.where(id: field_config_ids, root_field: false).pluck(:id)
    where(field_configuration_id: non_root_field_config_ids)
  }

  scope :drop_down_custom_fields_only, -> {
    field_config_ids = self.pluck(:field_configuration_id)
    drop_down_field_config_ids = FieldConfiguration.where(id: field_config_ids, field_type_id: FieldType.id_for(:drop_down)).pluck(:id)
    where(field_configuration_id: drop_down_field_config_ids)
  }

  scope :with_field_key, -> (key) { where field_key: key }

  before_save :set_field_key

  def set_value(value, save = true)
    if value.blank?
      if self.value.present?
        self.value.destroy
        self.value = nil
        self.save if save
      end
      return
    end

    field_type_id = field_configuration.field_type_id

    case field_type_id
    when FieldType.id_for(:text)
      if self.value.blank?
        self.value = FieldText.new
      end
      self.configured_field_value = value
      self.value.value = value
    when FieldType.id_for(:number)
      if self.value.blank?
        self.value = FieldNumber.new
      end
      self.value.value = value
    when FieldType.id_for(:decimal)
      if self.value.blank?
        self.value = FieldDecimal.new
      end
      self.value.value = value
    when FieldType.id_for(:boolean)
      if self.value.blank?
        self.value = FieldBoolean.new
      end
      self.value.value = value
    when FieldType.id_for(:drop_down)
      if self.value.blank?
        self.value = FieldDropDownSelection.new
      end
      value_text = FieldDropDownItem.find_by_id(value)&.name
      if self.field_configuration.present? and self.field_configuration.drop_down_items.present? and self.field_configuration.drop_down_items.with_id(value).present?
        self.value.value_id = value
        self.configured_field_value = value_text
      end
    when FieldType.id_for(:date)
      if self.value.blank?
        self.value = FieldDate.new
      end
      self.value.value = DateUtils.datetime_in_ist(value)
    when FieldType.id_for(:datetime)
      if self.value.blank?
        self.value = FieldDateTime.new
      end
      self.value.value = DateUtils.datetime_in_ist(value)
    when FieldType.id_for(:amount)
      if self.value.blank?
        self.value = FieldAmount.new
      end
      if self.value.value_id.blank?
        # value.value is Amount
        self.value.value = Amount.new
      end
      # value.value is Amount, so setting Amounts value becomes value(CustomField.value).value(FieldAmount.value).value(Amount.value)
      self.value.value.value = value
      # value.value is Amount, so setting Amounts currency_id becomes value(CustomField.value).value(FieldAmount.value).currency_id(Amount.currency_id)
      self.value.value.currency_id = 1
    when FieldType.id_for(:multiselect)
      # here self.value should ideally be an object of FieldMultiselectSelection
      if self.value.blank?
        self.value = FieldMultiselectSelection.new(field_multiselect_selection_items_attributes: [])
      end
      # now set the individual values that are passed as the new values of the multi select
      self.value.field_multiselect_selection_items.destroy_all # destroy the existing ones and create the new ones, I guess?
      value.each do |val|
        item = self.value.field_multiselect_selection_items.build(value_id: val)
      end
    else
      # do nothing?
    end
    self.value.save if self.value.present? and save
  end

  def string_value
    case field_configuration.field_type_id
    when FieldType.id_for(:text)
      return self.value&.value
    when FieldType.id_for(:drop_down)
      return self.value&.value&.name
    when FieldType.id_for(:multiselect)
      names = []
      self.value&.field_multiselect_selection_items&.each do |item|
        names << item.value&.name
      end
      return names.to_sentence
    else
      # do nothing?
    end
  end

  def as_json(options = {})
    user_level_custom_fields = self.field_configuration.user_level_field
    case
    when options[:report_show]
      return report_show
    when options[:report_mailer_show] # Show page when user navigates from email
      return report_mailer_show
    else
      options = []
      dependent_field_configuration_ids = []
      has_dependent_cf = false
      if field_configuration.field_type_id == FieldType.id_for(:drop_down)
        if user_level_custom_fields
          option_ids = field_configuration.drop_down_items.exclude_deleted.filter_user_id(RequestStore.store[:current_user]&.id).includes(:dependent_field_configurations).find_each(batch_size: 100).reject(&:nil?)
          options = FieldDropDownItem.where(id: option_ids)
        else
          options = field_configuration.drop_down_items.exclude_deleted
        end
        # options.each do |option|
        #   if option.dependent_field_configurations.present?
        #     dependent_field_configuration_ids += option.dependent_field_configurations.pluck(:id)
        #     has_dependent_cf = true
        #   end
        # end
        dependent_field_configuration_ids = options.joins(:dependent_field_configurations).pluck('field_configurations.id')
        has_dependent_cf = true if dependent_field_configuration_ids.present?

      elsif field_configuration.field_type_id == FieldType.id_for(:multiselect)
        options = field_configuration.multiselect_items
      end
      json = {id: field_configuration.id,
              label: field_configuration.field_name,
              field_type: {id: field_configuration.field_type.id,
                           name: field_configuration.field_type.name},
              mandatory: field_configuration.mandatory,
              options: options,
              root_field: self.field_configuration.root_field,
              dependent_field_configuration_ids: dependent_field_configuration_ids&.uniq,
              has_dependent_cf: has_dependent_cf
      }
      case self.field_configuration.field_type_id
      when FieldType.id_for(:multiselect)
        ids = []
        names = []
        self.value&.field_multiselect_selection_items&.each do |item|
          ids << item.value_id
          names << item.value&.name
        end
        json["#{field_configuration.field_type.name.to_sym}_field_value"] = {
            ids: ids,
            names: names
        }
      else
        json["#{field_configuration.field_type.name.to_sym}_field_value"] = self.value
      end
      json
    end
  end

  def report_show
    json = {
        id: field_configuration.id,
        label: field_configuration.field_name,
        field_type: {id: field_configuration.field_type.id,
                     name: field_configuration.field_type.name},
        mandatory: field_configuration.mandatory,
        options: {},
        root_field: self.field_configuration.root_field,
        dependent_field_configuration_ids: [],
        has_dependent_cf: false
    }
    json["#{field_configuration.field_type.name.to_sym}_field_value"] = self.value
    return json
  end

  def set_field_key
    self.field_key = self.field_configuration.field_key
  end

  def report_mailer_show
    {
        label: field_configuration.field_name,
        value: self.value
    }
  end

end
