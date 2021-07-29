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

class MasterEntity::LargeText < MasterEntity
  register :large_text
  database_type :text
  filter_type :large_text
  set :hint, "Enter value"
  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present
  simple_filter :cont_any

  MINIMUM_DEFAULT ||= 0
  MAXIMUM_DEFAULT ||= 65535

  option :minimum, default: MINIMUM_DEFAULT
  option :maximum, default: MAXIMUM_DEFAULT

  contract_eval 'Max Char Limit Check', &Masters::Schema::Validations::Templates[:maximum]
  contract_eval 'Min Char Limit Check', &Masters::Schema::Validations::Templates[:minimum]

  schema_contract do
    validates :options, presence: true
    validate :options_structure

    def options_structure
      if options['minimum'].blank?
        errors.add :minimum,  "cannot be blank"
      elsif options['maximum'].blank?
        errors.add :maximum, "cannot be blank"
      elsif options['minimum'].to_f < MINIMUM_DEFAULT
        errors.add :minimum, "has to be greater than or equal to #{MINIMUM_DEFAULT}"
      elsif options['maximum'].to_f > MAXIMUM_DEFAULT
        errors.add :maximum, "has to be less than or equal to #{MAXIMUM_DEFAULT}"
      elsif options['minimum'].to_f > options['maximum'].to_f
        errors.add :minimum, "has to be less than or equal to maximum"
      end
    end
  end
end
