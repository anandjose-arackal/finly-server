# == Schema Information
#
# Table name: yes_bank_vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class YesBankVendor < ActiveRecord::Base
  belongs_to :company
end
