# == Schema Information
#
# Table name: field_configurations
#
#  id                      :integer          not null, primary key
#  enabled                 :boolean          default(TRUE), not null
#  field_type_id           :integer          not null
#  mandatory               :boolean          default(FALSE), not null
#  company_id              :integer          not null
#  configurable_id         :integer
#  configurable_type       :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  field_name              :string(255)      not null
#  default_value_id        :integer
#  default_value_type      :string(255)
#  is_deleted              :boolean          default(FALSE), not null
#  global                  :boolean          default(TRUE)
#  external_reference_type :string(255)
#  external_reference_id   :integer
#  parent_id               :integer
#  parent_type             :string(255)
#  root_field              :boolean          default(TRUE)
#  field_key               :string(255)
#  sequence_number         :integer
#  deleted_at              :datetime
#  printable               :boolean          default(TRUE)
#  uuid                    :string(36)
#

class FieldConfiguration < ApplicationRecord
  include SoftDeletable

  # Global - When expense is split, used to determine if the custom field should appear in the split or in the root

  belongs_to :field_type, optional: true
  belongs_to :company, optional: true
  has_many :field_parent_mappings
  has_many :field_parent_types, through: :field_parent_mappings
  # belongs_to :field_parent_type, optional: true
  # Applicable for User, Policy, Company
  belongs_to :configurable, optional: true, polymorphic: true
  has_many :drop_down_items, class_name: 'FieldDropDownItem'
  has_many :multiselect_items, class_name: 'FieldMultiselectItem'
  has_many :custom_fields
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :default_value, optional: true, polymorphic: true
  belongs_to :external_reference, optional: true, polymorphic: true

  has_many :policy_field_mappings
  has_many :policies, through: :policy_field_mappings

  has_many :parent_dependent_field_configuration_mappings, foreign_key: :dependent_field_configuration_id
  has_many :parent_drop_down_items, through: :parent_dependent_field_configuration_mappings, source: :parent, source_type: "FieldDropDownItem"

  # adding associations with the related users as well
  has_many :user_field_mappings
  has_many :affected_users, through: :user_field_mappings, source: :user

  validates :field_name, presence: true
  validates :enabled, presence: true
  validates :field_type_id, presence: true
  validates :company_id, presence: true
  # validates :field_parent_type_id, presence: true
  # validates :configurable_id, presence: true
  validates_uniqueness_of :field_key, :allow_blank => true, :scope => [:company_id], :case_sensitive => false
  validates :configurable_type, presence: true, :inclusion => {:in => ['Policy', 'Company']} #, 'User']}
  validates :default_value_type, :inclusion => {:in => [nil, 'FieldAmount', 'FieldBoolean', 'FieldDate', 'FieldDateTime', 'FieldDecimal', 'FieldDropDownSelection', 'FieldNumber', 'FieldText', 'FieldMultiSelectSelection']}
  validate :validate_config
  validate :field_parent_type_presence

  accepts_nested_attributes_for :drop_down_items
  accepts_nested_attributes_for :custom_fields
  accepts_nested_attributes_for :multiselect_items
  accepts_nested_attributes_for :field_parent_mappings
  accepts_nested_attributes_for :policy_field_mappings
  accepts_nested_attributes_for :parent_dependent_field_configuration_mappings

  scope :with_id, -> (id) {where id: id}

  # scope :with_parent_type, ->(type_id) { where field_parent_type_id: type_id }
  # scope :with_parent_type, ->(type_id) {includes(:field_parent_mappings).where(field_parent_mappings: {field_parent_type_id: type_id})}
  scope :with_parent_type, ->(type_id) {joins(:field_parent_mappings).where(field_parent_mappings: {field_parent_type_id: type_id})}
  scope :enabled, -> {where enabled: true}
  scope :disabled, -> {where enabled: false}
  scope :filter_field_type_id, ->(type_id) {where field_type_id: type_id}
  scope :filter_parent_type_id, -> (type_id) {with_parent_type type_id}
  scope :order_created_at_desc, -> {order(created_at: :desc)}
  scope :with_company, -> (company_id) {where company_id: company_id}
  scope :with_field_parent_type, -> (parent_type_id) {with_parent_type parent_type_id}
  scope :with_field_type, -> (field_type_id) {where field_type_id: field_type_id}
  scope :root_fields, -> {where root_field: true}
  scope :non_root_fields, -> {where.not(root_field: true)}
  scope :with_field_key, ->(key) { where field_key: key }

  scope :filter_dropdowns, -> {where field_type_id: FieldType.id_for(:drop_down)}

  scope :include_for_index, -> {
    includes(:field_type, :policy_field_mappings, :policies, :field_parent_types, :multiselect_items, drop_down_items: [:dependent_field_configurations, :parent_dependent_field_configuration_mappings])
  }

  scope :filter_parent_drop_down_id, -> (drop_down_id) {
    joins(:parent_dependent_field_configuration_mappings).where('parent_dependent_field_configuration_mappings.parent_type = ? AND parent_dependent_field_configuration_mappings.parent_id IN (?)', "FieldDropDownItem", drop_down_id)
  }

  delegate :drop_down?, :multiselect?, to: :field_type
  delegate :text?, to: :field_type

  default_scope {unscope(:where).order(sequence_number: :asc, id: :asc)}

  def validate_config
    case field_type_id
    when FieldType.id_for(:drop_down)
      if drop_down_items.blank?
        self.errors.add(:drop_down, 'cannot be empty')
      end
    when FieldType.id_for(:multiselect)
      if multiselect_items.blank?
        self.errors.add(:multiselect, 'items cannot be empty')
      end
    end
    if default_value.present? and not default_value.valid?
      self.errors.add :invalid, 'input format for "default value"'
    end

    # IMP CONDITION - Expense Custom Field Configurations are always defined inside a policy while Expense Field Configuration are always defined inside Company
    parent_type_ids = self.field_parent_mappings.pluck_field_parent_type_id

    parent_type_ids.each do |id|
      if FieldParentType.expense_ids.include?(id) and configurable_type != 'Company'
        self.errors.add :invalid, 'config. Custom Expense Field can only be configured at an organisation level'
      end
    end

    # IMP CONDITION - Report and Money Request Field Configurations are always defined inside a policy while Expense Field Configuration are always defined inside Company
    parent_type_ids.each do |id|
      if [FieldParentType.id_for(:report), FieldParentType.id_for(:money_request)].include?(id) and configurable_type != 'Policy'
        self.errors.add :invalid, 'config. Custom Fields for Reports and Money Requests can only be configured at policy level'
      end
    end
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

  # Global - When expense is split, used to determine if the custom field should appear in the split or in the root
  def as_json(options = {})
    options = []
    # user_level_custom_fields = RequestStore.store[:current_user]&.company&.feature_subscription&.user_level_custom_fields? ? true : false
    user_level_custom_fields = self.user_level_field
    if field_type_id == FieldType.id_for(:drop_down)
      # options = drop_down_items.exclude_deleted
      if user_level_custom_fields
       options = drop_down_items.exclude_deleted.filter_user_id(RequestStore.store[:current_user]&.id).includes(:dependent_field_configurations).find_each(batch_size: 100).lazy.flat_map {|ddi| ddi if ddi.is_deleted == false}.reject(&:nil?)
      else
        options = drop_down_items.exclude_deleted.includes(:dependent_field_configurations).find_each(batch_size: 100).lazy.flat_map {|ddi| ddi if ddi.is_deleted == false}.reject(&:nil?)
      end
    elsif field_type_id == FieldType.id_for(:multiselect)
      options = multiselect_items.non_deleted
    end
    result = {
        id: id,
        label: field_name,
        field_type: {id: field_type.id,
                     name: field_type.name},
        mandatory: mandatory,
        global: self.global,
        # value: self.default_value,
        options: options,
        root_field: self.root_field,
        parent_drop_down_items: parent_drop_down_items
    }
    if [FieldType.id_for(:drop_down)].include?(self.field_type_id)
      # if self.drop_down_items.joins(:dependent_field_configurations).present?
      #   result[:has_dependent_cf] = true
      # end
      ddi = drop_down_items.pluck :id
      result[:has_dependent_cf] = true if ParentDependentFieldConfigurationMapping.where(parent_id: ddi).present?
      # self.drop_down_items.each do |drop_down|
      #   if drop_down.dependent_field_configurations.present?
      #     result[:has_dependent_cf] = true
      #     break
      #   end
      # end
    end
    return result
  end

  def validate_parent
    if !self.root_field && self.parent.blank?
      errors.add(:field_configuration, "cannot set a non-root custom field without a parent")
    end
  end

  def field_parent_type_presence
    if self.field_parent_mappings.blank?
      errors.add(:field_configuration, "has not defined a parent")
    end
    if self.configurable_type&.downcase == 'policy' and self.policy_field_mappings.blank?
      errors.add(:at_least, "one policy is required to create a custom field")
    end
  end

end
