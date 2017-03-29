# == Schema Information
#
# Table name: field_configurations
#
#  id                   :integer          not null, primary key
#  enabled              :boolean          default(TRUE), not null
#  field_type_id        :integer          not null
#  mandatory            :boolean          default(FALSE), not null
#  company_id           :integer          not null
#  field_parent_type_id :integer          not null
#  configurable_id      :integer          not null
#  configurable_type    :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  field_name           :string(255)      not null
#  default_value_id     :integer
#  default_value_type   :string(255)
#  is_deleted           :boolean          default(FALSE), not null
#

class FieldConfiguration < ActiveRecord::Base
  include SoftDeletable

  belongs_to :field_type
  belongs_to :company
  belongs_to :field_parent_type
  # Applicable for User, Policy, Company
  belongs_to :configurable, polymorphic: true

  has_many :drop_down_items, class_name: 'FieldDropDownItem'
  has_many :custom_fields
  belongs_to :default_value, polymorphic: true

  validates :field_name, presence: true
  validates :enabled, presence: true
  validates :field_type_id, presence: true
  # validates :mandatory, presence: true
  validates :company_id, presence: true
  validates :field_parent_type_id, presence: true
  validates :configurable_id, presence: true
  validates :configurable_type, presence: true, :inclusion => {:in => ['Policy', 'Company']} #, 'User']}
  validates :default_value_type, :inclusion => {:in => [nil, 'FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText']}
  validate :validate_config

  accepts_nested_attributes_for :drop_down_items
  accepts_nested_attributes_for :custom_fields

  scope :with_id, -> (id) { where id: id }
  scope :with_parent_type, ->(type_id) {where field_parent_type_id: type_id}
  scope :enabled, -> { where enabled: true }
  scope :disabled, -> { where enabled: false }

  def validate_config
    case field_type_id
      when FieldType.id_for(:drop_down)
        if drop_down_items.blank?
          self.errors.add(:drop_down, 'cannot be empty')
        end
    end
    if default_value.present? and not default_value.valid?
      self.errors.add :invalid, 'input format for "default value"'
    end
    if FieldParentType.expense_ids.include?(self.field_parent_type_id) and configurable_type != 'Company'
      self.errors.add :invalid, 'config. Custom Expense Field can only be configured at an organisation level'
    end
    # # Policy custom fields can only be added for expenses as policy is not captured at the time of expense
    # if field_parent_type_id == FieldParentType.id_for(:expense) and configurable_type == 'Policy'
    #   add_message :error, 'Custom expense field cannot be added at a policy level'
    #   return
    # end
    # if default_value.present?
    #   result = CustomField::Configuration::ValidateFieldValue.(value: default_value, config: self)
    #   unless result.success?
    #     result.messages[:error].each do |error|
    #       self.errors.add :error, ": #{error}"
    #     end
    #   end
    # end
  end

  def set_default_value(value)
    if value.blank?
      if default_value.present?
        default_value.destroy
        self.default_value = nil
        self.save
      end
      return
    end

    case field_type_id
      when FieldType.id_for(:text)
        if default_value.blank?
          self.default_value = FieldText.new
        end
        self.default_value.value = value
      when FieldType.id_for(:number)
        if default_value.blank?
          self.default_value = FieldNumber.new
        end
        self.default_value.value = value
      when FieldType.id_for(:decimal)
        if default_value.blank?
          self.default_value = FieldDecimal.new
        end
        self.default_value.value = value
      when FieldType.id_for(:boolean)
        if default_value.blank?
          self.default_value = FieldBoolean.new
        end
        self.default_value.value = value
      when FieldType.id_for(:drop_down)
        if default_value.blank?
          self.default_value = FieldDropDownSelection.new
        end
        self.default_value.value_id = value if self.drop_down_items.with_id(value).present?
      when FieldType.id_for(:date)
        if default_value.blank?
          self.default_value = FieldDate.new
        end
        self.default_value.value = DateUtils.datetime_in_ist(value)
      when FieldType.id_for(:datetime)
        if default_value.blank?
          self.default_value = FieldDateTime.new
        end
        self.default_value.value = DateUtils.datetime_in_ist(value)
      when FieldType.id_for(:amount)
        if default_value.blank?
          self.default_value = FieldAmount.new
        end
        if self.default_value.value_id.blank?
          # default_value.value is Amount
          self.default_value.value = Amount.new
        end
        # value.value is Amount, so setting Amounts value becomes default_value(CustomField.value).value(FieldAmount.value).value(Amount.value)
        self.default_value.value.value = value
        # value.value is Amount, so setting Amounts currency_id becomes default_value(CustomField.value).value(FieldAmount.value).currency_id(Amount.currency_id)
        self.default_value.value.currency_id = 1
    end
    self.default_value.save if self.default_value.present?
  end

end
