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

  def dynamic_model
    model = self.model
    return model if model.present?
    return @dynamic_model if @dynamic_model.present?

    table_name = self.table_name
    @dynamic_model = Class.new(ApplicationRecord) do
      self.table_name = table_name
    end
  end

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

end
