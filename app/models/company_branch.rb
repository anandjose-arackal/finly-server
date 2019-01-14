# == Schema Information
#
# Table name: company_branches
#
#  id                        :integer          not null, primary key
#  collect_company_detail_id :integer
#  name                      :string(255)
#  pan                       :string(255)
#  gst                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :integer
#  address_1                 :string(255)
#  address_2                 :string(255)
#  city                      :string(255)
#  state_id                  :integer
#  country                   :string(255)
#  pin                       :string(255)
#

class CompanyBranch < ApplicationRecord
  belongs_to :collect_company_detail, optional: true
end
