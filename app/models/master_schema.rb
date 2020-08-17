# == Schema Information
#
# Table name: master_schemas
#
#  id                        :bigint           not null
#  uuid                      :string(36)       not null, primary key
#  company_id                :integer
#  name                      :string(255)      not null
#  master_key                :string(255)      not null
#  model                     :string(255)
#  klass_name                :string(255)
#  active                    :boolean          default(TRUE)
#  system_master             :boolean
#  can_name_be_changed       :boolean
#  can_attributes_be_nested  :boolean
#  can_attributes_be_changed :boolean
#  deleted_at                :datetime
#  owner_id                  :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class MasterSchema < ApplicationRecord
  include UUIDHelper, SoftDeletable, TemplateClonable
  include Masters::Entity::Registry
  include Masters::Entity::Record # Define the generation of anonymous record models
  include Masters::Entity::Exposure # Define the generation of anonymous exposures

  belongs_to :company
  belongs_to :owner, optional: true

  has_many :entities, class_name: 'MasterEntity'
  has_one :sequence_entity, -> { where type: 'MasterEntity::Sequence' }, class_name: 'MasterEntity'
  has_many :unique_entities, -> { where unique: true }, class_name: 'MasterEntity'

  scope :active, -> { where active: true }

  default_scope { order(created_at: :asc) }

  def model
    klass_name&.model
  end

  def table_name
    system_master ? master_key : "schema_#{company_id}_#{master_key}"
  end

  def klass_name
    val = super()
    return nil unless val.present?

    Object.const_get(val)
  end

  def contract
    Masters::Schema::Records::Contract.with(self)
  end

  def as_json(options = {})
    {
        name: name,
        master_key: master_key,
        entities: entities
    }
  end

end
