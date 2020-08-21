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

class MasterEntity::Text < MasterEntity
  register :text
  database_type :string
  simple_filter :cont_any
  set :hint, 'Enter value'
  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present
end
