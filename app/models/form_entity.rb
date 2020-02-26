# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  company_id                   :integer          not null
#  form_id                      :integer          not null
#  form_section_id              :integer          not null
#  created_by_user_id           :integer
#  field_key                    :string(255)      not null
#  label                        :string(255)
#  placeholder                  :boolean
#  hint                         :boolean
#  field_type                   :boolean
#  default_value                :boolean
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :boolean
#  custom_field                 :boolean
#  dependent                    :boolean
#  conditional_requiredg        :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_not_be_hidden            :boolean
#  can_be_filtered              :boolean
#  can_choices_be_changed       :boolean
#  show_in_bulk_import          :boolean
#  allow_sort_in_filter         :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  chained                      :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  deleted_at                   :datetime
#  scope                        :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  field_path                   :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  associate_custom_fields      :boolean          default(FALSE)
#

class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper
  include Forms::Generators::Contracts::ModelHelpers::FormEntity
  include Forms::Generators::Filters::ModelHelpers::FormEntity

  belongs_to :company
  belongs_to :form_section
  belongs_to :form
  belongs_to :parent, class_name: 'FormEntity', optional: true, primary_key: :uuid, foreign_key: :parent_id
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :created_by_user_id

  has_many :entities, class_name: 'FormEntity', foreign_key: :parent_id, primary_key: :uuid
  has_many :choices, class_name: 'FormEntityChoice', dependent: :destroy

  accepts_nested_attributes_for :choices

  serialize :options, JSON
  serialize :chained, JSON
  serialize :scope, JSON

  scope :root, -> {where parent_id: nil}
  scope :system_fields, -> {where.not custom_field: true}
  scope :custom_fields, -> {where custom_field: true}

  def populate_if_empty
    val = super()
    return nil unless val

    Object.const_get(val)
  end

  def scope
    val = super()&.with_indifferent_access
    return nil unless val.present?

    handler = Forms::API::Entity::Scope.handler(val[:type])
    handler.new val, self
  end

  def schema
    {
        field_key: field_key,
        label: label,
        placeholder: placeholder,
        hint: hint,
        field_type: field_type,
        default_value: default_value,
        multiple: multiple,
        editable: editable,
        required: required,
        active: active,
        unique: unique,
        visible: visible,
        position: position,
        custom_field: custom_field,
        dependent: dependent,
        conditional_required: conditional_required,
        can_visible_be_changed: can_visible_be_changed,
        can_editable_be_changed: can_editable_be_changed,
        can_required_be_changed: can_required_be_changed,
        can_uniqueness_be_changed: can_uniqueness_be_changed,
        can_be_disabled: can_be_disabled,
        can_label_be_renamed: can_label_be_renamed,
        can_not_be_hidden: can_not_be_hidden,
        can_be_filtered: can_be_filtered,
        can_choices_be_changed: can_choices_be_changed,
        show_in_bulk_import: show_in_bulk_import,
        allow_sort_in_filter: allow_sort_in_filter,
        allow_clearing_default_value: allow_clearing_default_value,
        options: options,
        chained: chained,
        scope: scope,
        internal: internal,
        field_path: field_path
    }
  end

end
