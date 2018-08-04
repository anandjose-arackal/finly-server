# == Schema Information
#
# Table name: user_pockets
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  balance_id            :integer
#  user_pocket_type_id   :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_code          :string(255)
#  atm_withdrawal_pocket :boolean          default(FALSE)
#  user_id               :integer
#

class UserPocket < ActiveRecord::Base

  belongs_to :user_pocket_type
  belongs_to :balance, class_name: "Amount"
  belongs_to :user

end
