# == Schema Information
#
# Table name: user_pockets
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  balance_id          :integer
#  user_pocket_type_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class UserPocket < ActiveRecord::Base
end
