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

class MasterEntity::Date < MasterEntity
  register :date
  database_type :date
  filter_type :date
  set :hint, "Select date"
  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank

  RESTRICTIONS ||= %w(
    in_the_future
    in_the_past
    not_in_the_future
    not_in_the_past
  ).freeze

  option :restriction

  contract_eval 'Date validity' do |contract:, entity:, **|
    contract.validate do
      value = send(entity.entity_key)
      next unless value.present?

      begin
        date_format = '%Y-%m-%d'
        ::Date.strptime(value, date_format)
      rescue ArgumentError
        errors.add entity.label, 'invalid Date format'
      end
    end
  end

  contract_eval 'Restriction' do |contract:, entity:, **|
    if entity.options['restriction'].present?
      contract.validate do
        value = send(entity.entity_key)

        next unless value.present?

        case entity.options['restriction']
        when 'in_the_future'
          if ::Date.parse(value) <= ::Date.today
            errors.add entity.label, "can only be in the future"
          end
        when 'in_the_past'
          if ::Date.parse(value) >= ::Date.today
            errors.add entity.label, "can only be in the past"
          end
        when 'not_in_the_future'
          if ::Date.parse(value) > ::Date.today
            errors.add entity.label, "cannot be in the future"
          end
        when 'not_in_the_past'
          if ::Date.parse(value) < ::Date.today
            errors.add entity.label, "cannot be in the past"
          end
        else
          # Do nothing
        end
      end
    end
  end
end
