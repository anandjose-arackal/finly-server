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
#

class MasterEntity::Sequence < MasterEntity
  register :sequence
  simple_filter :cont_any
  set :hint, 'Auto-Generated'
  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  option :prefix
  option :min_length, default: 5

  schema_contract do
    validation do
      params do
        required(:options)
      end

      rule :options do
        if value[:prefix].blank?
          key.failure "Prefix cannot be blank"
        elsif value[:min_length].blank?
          key.failure "Min length cannot be blank"
        elsif value[:min_length] < 0
          key.failure "Min length has to be greater than 0"
        elsif value[:min_length] > 10
          key.failure "Min length has to be less than 10"
        end
      end
    end
  end

  contract_eval "Set sequence" do |context|
    context[:contract].after_save do
      # Todo add after save handler here
    end
  end
end
