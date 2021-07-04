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

class MasterEntity::Integer < MasterEntity
  register :integer
  database_type :integer
  filter_type :number
  set :hint, 'Enter value'
  operators :gteq, :lteq, :in, :not_in, :not_null, :null

  option :max_value
  option :min_value

  contract_eval 'Max Value Limit Check', &Masters::Schema::Validations::Templates[:max_value]
  contract_eval 'Min Value Limit Check', &Masters::Schema::Validations::Templates[:min_value]

  schema_contract do
    validates :options, presence: false
    validate :options_structure

    def options_structure
      if options.present? && options['min_value'].present? and options['max_value'].present?
        if options['min_value'].to_f > options['max_value'].to_f
          errors.add :min_value, "has to be less than or equal to max_value"
        end
      end
    end
  end
end
