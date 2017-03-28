# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  parent_id              :integer          not null
#  parent_type            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_id               :integer          not null
#  value_type             :string(255)      not null
#

class CustomField < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :parent, polymorphic: true

  # If the custom field is destroyed, destroyed its associated value
  belongs_to :value, polymorphic: true, dependent: :destroy

  # validate :validate_field

  validates :field_configuration_id, presence: true
  validates :parent_id, presence: true
  validates :parent_type, presence: true, :inclusion => {:in => ['ManualExpense', 'TimeExpense', 'PerDiemExpense', 'DistanceExpense', 'Report', 'MoneyRequest']}
  validates :value_type, :inclusion => {:in => [nil, 'FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText']}

  scope :with_field_configuration_ids, ->(ids) { where field_configuration_id: ids }

  def set_value(value, save = true)
    if value.nil?
      if self.value.present?
        self.value.destroy
        self.value = nil
        self.save if save
      end
      return
    end

    case field_type_id
      when FieldType.id_for(:text)
        if value.blank?
          self.value = FieldText.new
        end
        self.value.value = value
      when FieldType.id_for(:number)
        if value.blank?
          self.value = FieldNumber.new
        end
        self.value.value = value
      when FieldType.id_for(:decimal)
        if value.blank?
          self.value = FieldDecimal.new
        end
        self.value.value = value
      when FieldType.id_for(:boolean)
        if value.blank?
          self.value = FieldBoolean.new
        end
        self.value.value = value
      when FieldType.id_for(:drop_down)
        if value.blank?
          self.value = FieldDropDownSelection.new
        end
        if self.field_configuration.present? and self.field_configuration.drop_down_items.present? and self.field_configuration.drop_down_items.with_id(value).present?
          self.value.value_id = value
        end
      when FieldType.id_for(:date)
        if value.blank?
          self.value = FieldDate.new
        end
        self.value.value = DateUtils.datetime_in_ist(value)
      when FieldType.id_for(:datetime)
        if value.blank?
          self.value = FieldDateTime.new
        end
        self.value.value = DateUtils.datetime_in_ist(value)
      when FieldType.id_for(:amount)
        if value.blank?
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
    end
    self.value.save if self.value.present? and save
  end

end
