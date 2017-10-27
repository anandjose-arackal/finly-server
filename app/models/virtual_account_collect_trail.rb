# == Schema Information
#
# Table name: virtual_account_collect_trails
#
#  id                     :integer          not null, primary key
#  found_virtual_account  :boolean
#  update_company_balance :boolean
#  create_payment         :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class VirtualAccountCollectTrail < ActiveRecord::Base
end
