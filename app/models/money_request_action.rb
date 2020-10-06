# == Schema Information
#
# Table name: money_request_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#


class MoneyRequestAction < NonTenantedApplicationRecord
end
