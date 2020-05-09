class FormEntity::Date < FormEntity
  register :datetime
  set :hint, "Select date and time"

  operators :gteq_days, :lteq_days, :eq_days, :in_days, :eq_any, :gteq, :lteq, :blank
end