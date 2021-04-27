# == Schema Information
#
# Table name: budget_date_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BudgetDateType < NonTenantedApplicationRecord
  include Seedable

  def self.values
    %w(
      entity_date
      entity_submitted_at
      entity_created_at
    )
  end
end
