# == Schema Information
#
# Table name: company_branches
#
#  id                        :integer          not null, primary key
#  collect_company_detail_id :integer
#  name                      :string(255)
#  address                   :text(65535)
#  pan                       :string(255)
#  gst                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CompanyBranch < ActiveRecord::Base
  belongs_to :company
end
