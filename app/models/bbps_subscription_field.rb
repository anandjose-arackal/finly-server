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
#

class BbpsSubscriptionField < ApplicationRecord

  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true

end
