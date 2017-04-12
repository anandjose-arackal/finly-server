# == Schema Information
#
# Table name: payment_order_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentOrderStatus < ActiveRecord::Base

  VALUES = {cancelled: 1, pending: 2, in_progress: 3, completed: 4, partial_complete: 5, failed: 6, scheduled: 7}
  # Cancelled, In Progress, Completed, Partial Complete, Failed, Scheduled

  validates :name, presence: true

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == PaymentOrderStatus.count
    VALUES.each do |key, value|
      if count == 0 or PaymentOrderStatus.with_name(value).blank?
        PaymentOrderStatus.create id:value, name: key
      end
    end
  end

end
