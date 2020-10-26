# == Schema Information
#
# Table name: form_rule_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FormRuleType < NonTenantedApplicationRecord
  include Seedable

  set_values :value, :entity, :formula, :none

end
