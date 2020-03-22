class Forms::API::Entity::Types::Date < Forms::API::Entity::Base
  register :date
  hint "Select date"

  operators :gt_eq, :lt_eq
end