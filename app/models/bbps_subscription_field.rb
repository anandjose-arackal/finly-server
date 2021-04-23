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

class BbpsSubscriptionField < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true
  belongs_to :biller, class_name: 'BbpsBiller', foreign_key: :biller_id, optional: true

  def as_json(options = {})
    {id: id, label: label, value: value}
  end

  scope :without_biller_id, -> (id) {
    where.not(biller_id: id)
  }

end
