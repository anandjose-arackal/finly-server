# == Schema Information
#
# Table name: master_entities
#
#  id                        :bigint           not null
#  uuid                      :string(36)       not null, primary key
#  master_schema_id          :string(255)      not null
#  company_id                :integer
#  type                      :string(255)      not null
#  hint                      :string(255)
#  required                  :boolean
#  unique                    :boolean
#  position                  :string(255)
#  entity_key                :string(255)      not null
#  system_entity             :boolean          default(FALSE)
#  label                     :string(255)      not null
#  active                    :string(255)
#  visible                   :boolean          default(TRUE)
#  identifier                :boolean          default(FALSE)
#  options                   :text(65535)
#  can_label_be_changed      :boolean
#  can_uniqueness_be_changed :boolean
#  can_mandatory_be_changed  :boolean
#  can_active_be_changed     :boolean
#  can_be_destroyed          :boolean
#  show_in_lookup            :boolean
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  choices_scope             :text(65535)
#

class MasterEntity < ApplicationRecord
  include UUIDHelper, SoftDeletable, TemplateClonable
  include DynamicAttributes
  include Dry::Monads[:result]
  include Masters::Entity::Schema
  include Masters::Entity::Filters

  belongs_to :company
  belongs_to :master_schema

  has_many :choices, class_name: 'MasterEntityChoice', dependent: :destroy

  scope :system_fields, -> { where system_entity: true }
  scope :custom_fields, -> { where.not system_entity: true }
  scope :show_in_lookup, -> { where show_in_lookup: true }

  class_attr :registered_type

  class_attr :contract_evaluators, default: {}

  serialize :options, JSON
  serialize :choices_scope, JSON

  def self.register(key)
    Masters::Entity::Registry.register self, key
  end

  def self.contract_eval(name, &block)
    contract_evaluators[name] = block if block_given?
  end

  contract_eval "Required check" do |contract:, entity:, **|
    if entity.required
      contract.validates entity.entity_key, presence: true
    end
  end

  contract_eval "Uniqueness check" do |contract:, entity:, **|
    if entity.unique
      contract.validates_uniqueness_of entity.entity_key, scope: [:company_id], conditions: -> { where deleted_at: nil }
    end
  end

  contract_eval "Choices Scope" do |contract:, entity:, **|
    if entity.choices_scope.present?
      contract.validate do
        id = send(entity.entity_key)
        if id.present?
          # If the master has a created by, use the created by field for scoping down the master
          user = contract_root.respond_to?(:created_by) ? contract_root.created_by : RequestStoreUtil.current_user
          unless entity.choices_scope.valid?(id: id, user: user)
            errors.add entity.entity_key, 'is invalid'
          end
        end
      end
    end
  end

  def choices_scope
    val = super()&.with_indifferent_access
    return nil unless val.present?

    Choices[val[:type]].new(val[:config], entity: self)
  end

  def type?(name)
    self.class.registered_type.to_s == name.to_s
  end

  def as_json(options = {})
    registered_type = self.class.registered_type
    if registered_type.nil? and type.present?
      registered_type = Object.const_get(type).registered_type
    end
    {
        id: id,
        label: label,
        hint: hint,
        entity_type: registered_type,
        position: position,
        required: required,
        unique: unique,
        primary_key: primary_key,
        entity_key: entity_key
    }
  end

end
