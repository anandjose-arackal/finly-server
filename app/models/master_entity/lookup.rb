# == Schema Information
#
# Table name: master_entities
#
#  id                        :bigint           not null, primary key
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

class MasterEntity::Lookup < MasterEntity
  register :lookup
  database_type :string
  set :hint, 'Select value'
  operators :eq_any #, :blank, :present

  option :route

  schema_contract do
    validate :entity_key_format

    def entity_key_format
      unless self.entity_key&.end_with?('_id')
        errors.add :entity_key, 'has to end with _id'
      end
    end
  end

  def route
    choices_scope&.route
  end

  def lookup_master_key
    @master_key ||= route&.split(".")&.last
  end

  def lookup_master_schema
    return nil if lookup_master_key.blank?

    company.master_schemas.find_by(master_key: lookup_master_key)
  end

  # Strips the _id from the record keys
  def association_name
    if entity_key.end_with?('_id')
      entity_key[0..(entity_key.length - 4)]
    else
      entity_key
    end
  end
end
