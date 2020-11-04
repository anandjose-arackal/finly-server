class FormEntity::Datetime < FormEntity
  register :datetime
  set :hint, "Select date and time"

  RESTRICTIONS = %w(
    in_the_future
    in_the_past
    not_in_the_future
    not_in_the_past
  ).freeze

  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank

  contract_eval 'Restriction' do |contract:, entity:, **|
    if entity.options['restriction'].present?
      contract.validate do
        value = send(entity.entity_key)

        next unless value.present?

        case entity.options['restriction']
        when 'in_the_future'
          if value.in_time_zone <= DateTime.now
            errors.add entity.entity_key, "can only be in the future"
          end
        when 'in_the_past'
          if value.in_time_zone >= DateTime.now
            errors.add entity.entity_key, "can only be in the past"
          end
        when 'not_in_the_future'
          if value.in_time_zone > DateTime.now
            errors.add entity.entity_key, "cannot be in the future"
          end
        when 'not_in_the_past'
          if value.in_time_zone < DateTime.now
            errors.add entity.entity_key, "cannot be in the past"
          end
        else
          # Do nothing
        end
      end
    end
  end

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:options) do
            hash do
              optional(:restriction)
            end
          end
        end
        rule(:options) do
          restriction = value[:restriction]
          key.failure("> restriction must be one of #{FormEntity::Datetime::RESTRICTIONS.join(", ")}") if FormEntity::Date::RESTRICTIONS.exclude?(restriction) && restriction.present?
        end
      end
    end
  end
end