# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                   :bigint           not null, primary key
#  bbps_biller_id       :bigint           not null
#  name                 :string(255)      not null
#  sequence_id          :string(255)      not null
#  department_id        :integer
#  cost_center_id       :integer
#  location_id          :integer
#  policy_id            :integer
#  deleted_at           :datetime
#  active               :boolean          default(TRUE)
#  note                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  status_id            :integer          not null
#  user_id              :integer
#  agreement_id         :integer
#  expected_due_day     :string(255)
#  controlling_level_id :integer
#  reminder_day         :string(255)
#

require 'rails_helper'

RSpec.describe BbpsBillerSubscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
