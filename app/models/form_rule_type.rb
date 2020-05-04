class FormRuleType < ApplicationRecord
  include Seedable

  set_values :value, :entity, :formula

end
