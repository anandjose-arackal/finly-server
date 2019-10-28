# == Schema Information
#
# Table name: bbps_biller_subscriptions
#
#  id                       :bigint           not null, primary key
#  bbps_biller_id           :bigint           not null
#  name                     :string(255)      not null
#  customer_params          :text(65535)
#  department_id            :integer
#  cost_center_id           :integer
#  location_id              :integer
#  policy_id                :integer
#  note                     :text(65535)
#  created_by_user_id       :integer
#  active                   :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  status_id                :integer          not null
#  deleted_at               :datetime
#  subscription_id          :string(255)
#  require_poc_verification :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe BbpsBillerSubscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
