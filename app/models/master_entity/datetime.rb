class MasterEntity::Date < MasterEntity
  register :datetime
  database_type :datetime
  filter_type :datetime
  set :hint, "Select date and time"
  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank

  RESTRICTIONS ||= %w(
    in_the_future
    in_the_past
    not_in_the_future
    not_in_the_past
  ).freeze

  option :restriction

  contract_eval 'Restriction' do |contract:, entity:, **|
    if entity.options['restriction'].present?
      contract.validate do
        value = send(entity.entity_key)

        next unless value.present?

        case entity.options['restriction']
        when 'in_the_future'
          if value.in_time_zone <= DateTime.now
            errors.add entity.label, "can only be in the future"
          end
        when 'in_the_past'
          if value.in_time_zone >= DateTime.now
            errors.add entity.label, "can only be in the past"
          end
        when 'not_in_the_future'
          if value.in_time_zone > DateTime.now
            errors.add entity.label, "cannot be in the future"
          end
        when 'not_in_the_past'
          if value.in_time_zone < DateTime.now
            errors.add entity.label, "cannot be in the past"
          end
        else
          # Do nothing
        end
      end
    end
  end

end