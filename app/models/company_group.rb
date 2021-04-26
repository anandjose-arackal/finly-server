# == Schema Information
#
# Table name: company_groups
#
#  id                 :bigint           not null, primary key
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_company_id :integer
#  deleted_at         :datetime
#

class CompanyGroup < NonTenantedApplicationRecord

  has_many :companies, foreign_key: :group_id
end
