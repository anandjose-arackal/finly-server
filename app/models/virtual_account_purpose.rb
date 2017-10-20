# == Schema Information
#
# Table name: virtual_account_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VirtualAccountPurpose < ActiveRecord::Base
end
