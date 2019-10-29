class BbpsSubscriptionField < ApplicationRecord

  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true

end
