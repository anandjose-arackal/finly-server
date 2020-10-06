# == Schema Information
#
# Table name: company_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class CompanyStatus < NonTenantedApplicationRecord
  include Seedable

  def self.values
    [:active, :partial_block, :deactivated, :hidden]
  end

end
