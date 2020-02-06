# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  uuid                         :string(36)       not null, primary key
#  company_id                   :integer          not null
#  form_id                      :string(36)       not null
#  form_section_id              :string(36)       not null
#  created_by_user_id           :integer
#  field_key                    :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  field_type                   :string(255)
#  default_value                :string(255)
#  multiple                     :boolean
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  custom_field                 :boolean
#  dependent                    :boolean
#  conditional_required         :boolean
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
#  scope                        :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  field_path                   :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#

class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :company
  belongs_to :form_section
  belongs_to :form
  belongs_to :parent, class_name: 'FormEntity', optional: true, primary_key: :uuid, foreign_key: :parent_id

  has_many :entities, class_name: 'FormEntity', foreign_key: :parent_id, primary_key: :uuid
  has_many :choices, class_name: 'FormEntityChoice', dependent: :destroy

  accepts_nested_attributes_for :choices

  serialize :options, JSON
  serialize :chained, JSON
  serialize :scope, JSON

  scope :root, -> { where parent_id: nil }
  scope :system_fields, -> { where.not custom_field: true }
  scope :custom_fields, -> { where custom_field: true }

  def populate_if_empty
    val = super()
    return nil unless val

    Object.const_get(val)
  end

  def scope
    val = super()&.with_indifferent_access
    return nil unless val.present?

    handler = Forms::DSL::Entity::Scope.handler(val[:type])
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

  def contract_property_options
    property_options = {}
    # In-case of custom fields, create a virtual field which is used for validations and dependencies
    if custom_field
      entity = self
      property_options[:virtual] = true
      property_options[:deserializer] = -> (input, represented, **) do
        associated_cf = represented.custom_fields.find { |custom_field| custom_field.form_entity_id == entity.uuid }
        represented.send("#{entity.field_key}=", (associated_cf.value))
      end
    end

    if populate_if_empty.present? and not property_options[:populate_if_empty]
      property_options[:populate_if_empty] = populate_if_empty
    end
    property_options
  end

  def contract
    is_collection = (field_type == "collection")
    builder_args = [self, field_key, schema, contract_property_options, contract_block, collection: is_collection]
    transformer = Forms::Contracts::EntityBuilder.new(*builder_args)
    transformer.generate
  end

  def contract_block
    return nil unless entities.present?

    entity = self
    entities = self.entities

    lambda do |*args|
      instance_eval &Forms::Contracts::EntityBuilder::CustomField.setup(entities.custom_fields) if entity.associate_custom_fields

      entities.each do |entity|
        instance_eval &entity.contract
      end
    end
  end
end
