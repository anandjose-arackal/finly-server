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

  belongs_to :company
  belongs_to :owner, optional: true

  has_many :entities, class_name: 'MasterEntity'
  has_one :sequence_entity, -> { where type: 'MasterEntity::Sequence' }, class_name: 'MasterEntity'
  has_many :unique_entities, -> { where unique: true }, class_name: 'MasterEntity'

  scope :active, -> { where active: true }

  def model
    klass_name&.model
  end

  def table_name
    system_entity ? master_key : "schema_#{company_id}_#{master_key}"
  end

  def klass_name
    val = super()
    return nil unless val.present?

    Object.const_get(val)
  end

  def record_model_class
    return @record_model_class if @record_model_class.present?

    base_class = self.model.present? ? self.model : ApplicationRecord
    master_key = self.master_key
    master_schema = self
    table_name = self.table_name
    @record_model_class = Class.new(base_class) do
      include SoftDeletable

      self.table_name = table_name

      def self.name
        "Master#{table_name}"
      end

      define_method :as_json do |options={}|
        Masters::JsonBuilder.(master_schema, self)
      end
    end
  end

  def contract
    Masters::Schema::Records::Contract.with(self)
  end

  def as_json(options={})
    {
        name: name,
        master_key: master_key,
        entities: entities
    }
  end

end
