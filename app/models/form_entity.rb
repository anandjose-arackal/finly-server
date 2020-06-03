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
#  custom_field                 :boolean
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
#

class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper
  include TemplateClonable
  include DynamicAttributes
  include Dry::Monads[:result]
  # include Forms::Generators::Contracts::ModelHelpers::FormEntity
  # include Forms::Generators::Filters::ModelHelpers::FormEntity
  include Forms::Generators::Filters::ApiEntityHelper
  include Forms::API::Entity::Registry
  include Forms::API::Entity::Schema

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

  # Fixme: Delete this as it is available in Forms::API::Entity::Registry. Kept it commented for testing purpose
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
  scope :system_fields, -> { where.not custom_field: true }
  scope :custom_fields, -> { where custom_field: true }
  scope :exclude_internal, -> { where.not internal: true }

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

  def contract(reform, user)
    Forms::Contracts::Builders::FormEntity.({params: {entity: self, reform: reform}, current_user: user})
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

  # def choices(params: {}, user:)
  #   choices_scope&.choices(params: params, user: user)
  # end

  def as_json(opts = {})
    data = {
        # id: uuid,
        entity_key: entity_key,
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

end
