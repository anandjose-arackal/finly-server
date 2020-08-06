# == Schema Information
#
# Table name: master_schemas
#
#  id                        :bigint           not null
#  uuid                      :string(36)       not null, primary key
#  company_id                :integer
#  name                      :string(255)      not null
#  table_name                :string(255)      not null
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

  has_many :entities, class_name: "MasterEntity"

  scope :active, -> { where active: true }

  alias_attribute :master_key, :table_name

  def model
    val = super()
    return nil unless val.present?

    Object.const_get(val)
  end

  def klass_name
    val = super()
    return nil unless val.present?

    Object.const_get(val)
  end

  def record_model
    model = self.model
    return model if model.present?
    return @record_model if @record_model.present?

    table_name = self.table_name
    @record_model = Class.new(ApplicationRecord) do
      self.table_name = table_name
    end
  end

  def contract
    Masters::Schema::Records::Contract.build(self)
  end

end
