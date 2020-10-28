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