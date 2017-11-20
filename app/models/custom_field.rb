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
#

class CustomField < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :parent, polymorphic: true

  # If the custom field is destroyed, destroyed its associated value
  belongs_to :value, polymorphic: true, dependent: :destroy

  accepts_nested_attributes_for :value

  # validate :validate_field

  validates :field_configuration_id, presence: true
  validates :parent_type, :inclusion => {:in => ['ManualExpense', 'CardExpense', 'TimeExpense', 'PerDiemExpense', 'DistanceExpense', 'Report', 'MoneyRequest', 'Invoice']}
  validates :value_type, :inclusion => {:in => [nil, 'FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText']}

  scope :with_field_configuration_ids, ->(ids) { where field_configuration_id: ids }
  scope :includes_parent, -> { includes :parent }
  scope :expenses, -> { where parent_type: ['ManualExpense', 'CardExpense', 'TimeExpense', 'PerDiemExpense', 'DistanceExpense'] }
  scope :with_drop_down_selection, -> (drop_down_selection_id) { where value_type: 'FieldDropDownSelection', value_id: drop_down_selection_id }

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
        if self.field_configuration.present? and self.field_configuration.drop_down_items.present? and self.field_configuration.drop_down_items.with_id(value).present?
          self.value.value_id = value
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
          item = self.value.field_multiselect_selection_items.build(value: val)
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
    end
  end

  def as_json(options = {})
    options = []
    if field_configuration.field_type_id == FieldType.id_for(:drop_down)
      options = field_configuration.drop_down_items
    end
    json = {id: field_configuration.id,
            label: field_configuration.field_name,
            field_type: {id: field_configuration.field_type.id,
                         name: field_configuration.field_type.name},
            mandatory: field_configuration.mandatory,
            options: options}
    case self.field_configuration.field_type_id
      when FieldType.id_for(:multiselect)
        ids = []
        names = []
        self.value.field_multiselect_selection_items.each do |item|
          ids << item.id
          names << item.value.name
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
