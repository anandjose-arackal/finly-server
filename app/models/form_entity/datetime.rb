class FormEntity::Date < FormEntity
  register :datetime
  set :hint, "Select date and time"

  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank

  def self.option_validation
    Proc.new do
      validation :options_config do
        params do
          required(:options) do
            hash do
            end
          end
        end
      end
    end
  end
end