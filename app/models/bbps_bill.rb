# == Schema Information
#
# Table name: bbps_bills
#
#  id                   :bigint           not null, primary key
#  subscription_id      :integer
#  user_id              :integer
#  name                 :string(255)
#  sequence_id          :string(255)
#  department_id        :integer
#  cost_center_id       :integer
#  location_id          :integer
#  policy_id            :integer
#  controlling_level_id :integer
#  status_id            :integer
#  amount_id            :integer
#  autofetched          :boolean          default(FALSE)
#  expected_due_date    :date
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class BbpsBill < ApplicationRecord
end
