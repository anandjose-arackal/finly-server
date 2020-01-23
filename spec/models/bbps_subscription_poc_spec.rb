# == Schema Information
#
# Table name: bbps_subscription_pocs
#
#  id              :bigint           not null, primary key
#  user_id         :integer
#  subscription_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  uuid            :string(36)
#

require 'rails_helper'

RSpec.describe BbpsSubscriptionPoc, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
