# == Schema Information
#
# Table name: company_account_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyAccountType < ActiveRecord::Base
end
