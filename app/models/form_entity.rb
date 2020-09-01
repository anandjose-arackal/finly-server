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
#  entity_key                   :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  entity_type                  :string(255)
#  default_value                :string(255)
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  system_field                 :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_choices_be_changed       :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  choices_scope                :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  entity_path                  :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  type                         :string(255)
#  config                       :text(65535)
#  associate_custom_fields      :boolean
#  compute                      :boolean
#  compute_enabled              :boolean
#  compute_type_id              :integer
#  compute_formula              :string(255)
#  compute_lookup_entity_id     :string(255)
#  filters                      :text(65535)
#  config_path                  :string(255)
#

class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper
  include TemplateClonable
  include DynamicAttributes
  include Dry::Monads[:result]
  # include Forms::Generators::Contracts::ModelHelpers::FormEntity
  # include Forms::Generators::Filters::ModelHelpers::FormEntity
  include Forms::Generators::Filters::ApiEntityHelper
  include Forms::Entity::Registry
  include Forms::Entity::Schema

  class_attr :registered_type

  belongs_to :company
  belongs_to :section, class_name: "FormSection", foreign_key: :form_section_id
  belongs_to :form
  belongs_to :parent, class_name: 'FormEntity', optional: true, primary_key: :uuid, foreign_key: :parent_id
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :created_by_user_id
  belongs_to :compute_type, class_name: 'FormEntityComputationType', optional: true
  delegate :compute_lookup?, :compute_form?, to: :compute_type, allow_nil: true
  belongs_to :compute_lookup_entity, class_name: 'FormEntity', optional: true

  has_many :entities, class_name: 'FormEntity', foreign_key: :parent_id, primary_key: :uuid
  has_many :choices, class_name: 'FormEntityChoice', dependent: :destroy
  has_many :validations, class_name: 'FormEntityValidation'
  has_many :conditions, class_name: "FormCondition", as: :referencable

  has_many :choice_dependencies, class_name: "FormChoiceDependency", foreign_key: :dependent_entity_id
  has_many :choice_controlling_entities, through: :choice_dependencies, class_name: 'FormEntity', source: :controlling_entity

  before_save :sanitize

  # Fixme: Delete this as it is available in Forms::Entity::Registry. Kept it commented for testing purpose
  # def find_entity(entity_path)
  #   entities.each do |entity|
  #     return entity if entity.entity_path == entity_path
  #
  #     entity.find_entity(entity_path)
  #   end
  # end

  accepts_nested_attributes_for :choices

  serialize :options, JSON
  serialize :choices_scope, JSON
  serialize :config, JSON
  serialize :compute_formula, JSON

  scope :root, -> { where parent_id: nil }
  scope :system_fields, -> { where system_field: true }
  scope :custom_fields, -> { where.not system_field: true }
  scope :exclude_internal, -> { where.not internal: true }
  scope :computed, -> { where compute_enabled: true }
  scope :with_compute_type, -> (compute_type_id) { where compute_type_id: compute_type_id }

  serialize :filters, Rules::Adapters::Store

  def populate_if_empty
    val = super()
    return nil unless val

    Object.const_get(val)
  end

  def choices_scope
    val = super()&.with_indifferent_access
    return nil unless val.present?

    Choices[val[:type]].new(val[:config], form_entity: self)
  end

  def contract(contract, user)
    Forms::Contracts::Builders::FormEntity.({params: {entity: self, contract: contract}, current_user: user})
  end

  # Class method `contract` is used in Form Builder
  def self.contract(model, current_user)
    base_class = model.system_field ? Forms::Entities::Contracts::SystemFormEntity : Forms::Entities::Contracts::CustomFormEntity

    option_validation_proc = self.respond_to?(:option_validation) ? self.option_validation : nil

    dynamic_contract = Class.new(base_class) do

      instance_exec &option_validation_proc if option_validation_proc.present? && option_validation_proc.class == Proc

    end

    dynamic_contract.new(model, current_user: current_user)
  end

  def computed=(data)
    self.compute_enabled = true
    if data[:form].present?
      self.compute_type_id = FormEntityComputationType.id_for(:form)
      self.compute_formula = data&.dig(:form, :formula)
    elsif data[:lookup].present?
      self.compute_type_id = FormEntityComputationType.id_for(:lookup)
      self.compute_formula = data&.dig(:lookup, :formula)
      template_reference[:compute_lookup_entity_path] = data&.dig(:lookup, :lookup_entity_path)
    end
  end

  def parent_entity_path
    return nil if parent_id.nil?

    splits = entity_path.split(".")
    splits.pop
    splits.join('.')
  end

  def parent_entity_key
    return nil if parent_id.nil?

    splits = entity_path.split(".")
    splits.pop
    splits.last
  end

  # def choices(params: {}, user:)
  #   choices_scope&.choices(params: params, user: user)
  # end

  def as_json(opts = {})
    return form_reference_json(opts) if opts&.dig(:json_format)&.to_s == 'form_reference'
    return form_builder_json(opts) if opts&.dig(:json_format)&.to_s == 'form_builder'
    form_json(opts)
  end

  def form_builder_json(opts = {})
    params = opts[:params] || {}
    if choices_scope.present?
      choices_data = choices_scope.build(params: params, user: opts[:current_user])
    else
      choices_data = {choices: choices.as_json}
    end

    data = {
        id: id,
        uuid: uuid,
        company_id: company_id,
        form_id: form_id,
        form_section_id: form_section_id,
        created_by_user_id: created_by_user_id,
        entity_key: entity_key,
        label: label,
        placeholder: placeholder,
        hint: hint,
        entity_type: entity_type,
        default_value: default_value,
        behavior: {
            editable: editable,
            required: required,
            active: active,
            visible: visible,
        },
        unique: unique,
        position: position,
        custom_field: !system_field,
        can_visible_be_changed: can_visible_be_changed,
        can_editable_be_changed: can_editable_be_changed,
        can_required_be_changed: can_required_be_changed,
        can_uniqueness_be_changed: can_uniqueness_be_changed,
        can_be_disabled: can_be_disabled,
        can_label_be_renamed: can_label_be_renamed,
        can_choices_be_changed: can_choices_be_changed,
        allow_clearing_default_value: allow_clearing_default_value,
        options: options,
        deleted_at: deleted_at,
        created_at: created_at,
        updated_at: updated_at,
        internal: internal,
        is_modified: is_modified,
        entity_path: entity_path,
        parent_id: parent_id,
        populate_if_empty: populate_if_empty,
        type: type,
        config: config,
        associate_custom_fields: associate_custom_fields,
        compute_enabled: compute_enabled,
        compute_type_id: compute_type_id,
        compute_formula: compute_formula,
        compute_lookup_entity_id: compute_lookup_entity_id,
        filters: filters,
        config_path: config_path,
        validations: validations.as_json(options),
        conditions: conditions.as_json(options),
        # choices: choices_scope(params: options[:params], user: options[:current_user]),
        choices: choices_data
    }
  end

  def form_reference_json(opts = {})
    json = {
        entity_key: entity_key,
        entity_path: entity_path,
        config_path: config_path,
    }
    if parent.present? and parent.class.collection?
      json[:collection_entity_key] = parent.entity_key
      json[:collection_entity_path] = parent.entity_path
      json[:collection_config_path] = parent.config_path
    end
    json
  end

  def form_json(opts={})
    data = {
        id: uuid,
        entity_key: entity_key,
        parent_id: parent_id,
        system_field: system_field,
        entity_path: entity_path,
        config_path: config_path,
        label: label,
        placeholder: placeholder,
        hint: hint,
        entity_type: entity_type,
        default_value: default_value,
        position: position,
        behavior: {
            editable: editable,
            required: required,
            active: active,
            visible: visible,
        },
        options: options
    }
    if choices_scope.present?
      data[:choices] = choices_scope.build(params: opts[:params], user: opts[:current_user])
    end
    if entities.present?
      data[:entities] = {}
      entities.each do |ent|
        data[:entities][ent.entity_key] = ent.as_json(opts)
      end
    end
    data
  end


  def self.system_entity(section, entity_key, attributes)
    entity = self.new(
        section: section,
        entity_key: entity_key,
        parent: attributes[:parent],
        options: {},
        config: {}
    )
    schema = DEFAULT_SYSTEM_SCHEMA.deep_dup
    schema.deep_merge!(self.schema.deep_dup)
    schema.deep_merge!(attributes)
    schema[:options].each do |attr, value|
      entity.set attr, value, args: schema
    end
    schema[:config].each do |attr, value|
      entity.set attr, value, args: schema
    end
    schema.except(:options, :config)&.each do |attr, value|
      entity.set attr, value, args: schema
    end
    entity
  end

  def self.contract_evaluators
    @contract_evaluators ||= {}
  end

  def self.contract_eval(name, &block)
    contract_evaluators[name] = block if block_given?
  end

  def populate(represented, value)
    if populate_if_empty.present?
      populator = represented.send(entity_key)
      populator ||= populate_if_empty.new
      populator.assign_attributes(value)
      value = populator
    end
    # represented.send(entity_key).replace(value)
    represented.send("#{entity_key}=", value)
    represented.form_data[entity_key] = value
  end

  def populator
    nil
  end


  def generate_config_path(path = [], obj = self)
    return path if obj.blank?
    if obj.class.ancestors.map(&:name).include?('FormEntity')
      # Obj is an entity
      if obj.parent.present?
        path.unshift("entities", obj.entity_key)
        return generate_config_path(path, obj.parent)
      else
        path.unshift(obj.entity_key)
        return generate_config_path(path, obj.section)
      end

    elsif obj.class.ancestors.map(&:name).include?('FormSection')
      path.unshift(obj&.section&.section_id, "entities")
      return generate_config_path(path, obj.form)
    else
      path
    end
  end

  def generate_entity_path(path = [], obj = self)
    return path if obj.blank?

    if obj.class.ancestors.map(&:name).include?('FormEntity')
      # Obj is an entity
      if obj.parent.present?
        path.unshift(obj.entity_key)
        generate_entity_path(path, obj.parent)
      else
        path.unshift(obj.entity_key)
        generate_entity_path(path, obj.section)
      end
    else
      path
    end
  end


  private
  def sanitize
    # Set entity path & config path
    self.entity_path = generate_entity_path.join(".")
    self.config_path = generate_config_path.join(".")
  end

end
