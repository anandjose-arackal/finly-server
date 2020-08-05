# == Schema Information
#
# Table name: master_entities
#
#  id                        :bigint           not null
#  uuid                      :string(36)       not null, primary key
#  master_schema_id          :string(255)      not null
#  parent_id                 :string(255)
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
#  can_label_be_changed      :boolean
#  can_uniqueness_be_changed :boolean
#  can_mandatory_be_changed  :boolean
#  can_active_be_changed     :boolean
#  can_be_destroyed          :boolean
#  show_in_lookup            :boolean
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class MasterEntity < ApplicationRecord
  include UUIDHelper, SoftDeletable, TemplateClonable
  include DynamicAttributes
  include Dry::Monads[:result]
  include Masters::Entity::Schema
  include Masters::Entity::Filters

  belongs_to :company
  belongs_to :master_schema

  scope :system_fields, -> { where system_entity: true }
  scope :custom_fields, -> { where.not system_entity: true }

  class_attr :registered_type

  def self.register(key)
    Masters::Entity::Registry.register self, key
  end

  def as_json(options={})
    {
        label: label,
        hint: hint,
        type: self.class.registered_type,
        position: position,
        required: required,
        unique: unique,
        entity_key: entity_key
    }
  end

end
