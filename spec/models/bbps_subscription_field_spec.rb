# == Schema Information
#
# Table name: bbps_subscription_fields
#
#  id              :bigint           not null, primary key
#  label           :string(255)
#  value           :string(255)
#  subscription_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  biller_id       :integer
#  deleted_at      :datetime
#

require 'rails_helper'

RSpec.describe BbpsSubscriptionField, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
