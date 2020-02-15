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
#  deleted_at      :datetime
#

class BbpsSubscriptionPoc < ApplicationRecord
  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true
  belongs_to :user, optional: true

  def as_json(options = {})
    {
        id: id,
        user: user.json_for_trail
    }
  end
end
