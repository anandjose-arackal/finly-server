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
#  choices_scope             :text(65535)
#

class MasterEntity::Sequence < MasterEntity
  register :sequence
  simple_filter :cont_any
  set :hint, 'Auto-Generated'
  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  MIN_LENGTH_DEFAULT = 5

  option :prefix
  option :min_length, default: MIN_LENGTH_DEFAULT

  schema_contract do
    validates :options, presence: true
    validate :options_structure

    def options_structure
      if options['prefix'].blank?
        errors.add :prefix,  "cannot be blank"
      elsif options['min_length'].blank?
        errors.add :min_length, "cannot be blank"
      elsif options['min_length'] < 0
        errors.add :min_length, "has to be greater than 0"
      elsif options['min_length'] > 10
        errors.add :min_length, "has to be less than 10"
      end
    end
  end

  contract_eval "Set sequence" do |contract:, entity:, **|
    contract.after_save do
      if model.send(entity.entity_key).blank?
        prefix = entity.options['prefix']
        min_length = entity.options['min_length'] || MasterEntity::Sequence::MIN_LENGTH_DEFAULT
        prefix = LiquidHelper.interpolate(prefix, {'record' => model})
        sequence = REDIS.incr("MasterEntity::Sequence##{entity.id}##{prefix}")
        sequence = sequence.to_s.rjust(min_length, "0")
        model.send("#{entity.entity_key}=", "#{prefix}#{sequence}")
        model.save
      end
    end
  end
end
