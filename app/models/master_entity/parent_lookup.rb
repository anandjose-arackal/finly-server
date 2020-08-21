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
#  options                   :text(65535)
#  can_label_be_changed      :boolean
#  can_uniqueness_be_changed :boolean
#  can_required_be_changed   :boolean
#  can_active_be_changed     :boolean
#  can_be_destroyed          :boolean
#  show_in_lookup            :boolean
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  choices_scope             :text(65535)
#  primary_key               :boolean
#

class MasterEntity::ParentLookup < MasterEntity
  register :parent_lookup
  database_type :parent_lookup
  set :hint, 'Select Parent'
  operators :eq_any, :blank

  ATTRIBUTES = {
      entity_key: 'parent_id',
      required: false,
      unique: false,
      can_label_be_changed: true,
      can_uniqueness_be_changed: false,
      can_required_be_changed: false,
      can_active_be_changed: false,
      can_be_destroyed: false,
      show_in_lookup: true,
      primary_key: false
  }.with_indifferent_access

  def initialize(attributes = {})
    super(attributes.merge(ATTRIBUTES))
  end

  schema do
    validate :entity_key_format

    def entity_key_format
      unless entity_key == 'parent_id'
        errors.add :entity_key, 'has be to parent_id'
      end
    end
  end

end
