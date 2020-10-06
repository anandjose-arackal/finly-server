# == Schema Information
#
# Table name: company_funds_load_request_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#

class CompanyFundsLoadRequestType < NonTenantedApplicationRecord
  include Seedable

  def self.values
    [:itzcash, :yesbank]
  end
end
