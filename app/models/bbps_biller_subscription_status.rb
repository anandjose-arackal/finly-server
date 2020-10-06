# == Schema Information
#
# Table name: bbps_biller_subscription_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BbpsBillerSubscriptionStatus < NonTenantedApplicationRecord
  include Seedable

  GROUP_AWAITING_APPROVAL = 91

  def self.values
    %i(draft awaiting_approval retracted rejected approved auto_approved deactivated reactivated)
  end

  def draft?
    self.id == BbpsBillerSubscriptionStatus.id_for(:draft)
  end

  def awaiting_approval?
    self.id == BbpsBillerSubscriptionStatus.id_for(:awaiting_approval)
  end

  def retracted?
    self.id == BbpsBillerSubscriptionStatus.id_for(:retracted)
  end

  def rejected?
    self.id == BbpsBillerSubscriptionStatus.id_for(:rejected)
  end

  def approved?
    self.id == BbpsBillerSubscriptionStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == BbpsBillerSubscriptionStatus.id_for(:auto_approved)
  end

  def deactivated?
    self.id == BbpsBillerSubscriptionStatus.id_for(:deactivated)
  end

  def reactivated?
    self.id == BbpsBillerSubscriptionStatus.id_for(:reactivated)
  end

  def as_json
    {
        id: id,
        name: name,
        display_name: name.split("_").map(&:capitalize).join(" ")
    }
  end
end
