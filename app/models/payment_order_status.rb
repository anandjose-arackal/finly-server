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

  VALUES = {cancelled: 1, pending: 2, in_progress: 3, completed: 4, partially_completed: 5, failed: 6, scheduled: 7}
  # Cancelled, In Progress, Completed, Partial Complete, Failed, Scheduled

  validates :name, presence: true

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == PaymentOrderStatus.count
    VALUES.each do |key, value|
      if count == 0 or PaymentOrderStatus.with_name(key).blank?
        PaymentOrderStatus.create id:value, name: key
      end
    end
  end

  def cancelled?
    self.id == PaymentOrderStatus.id_for(:cancelled)
  end

  def pending?
    self.id == PaymentOrderStatus.id_for(:pending)
  end

  def in_progress?
    self.id == PaymentOrderStatus.id_for(:in_progress)
  end

  def completed?
    self.id == PaymentOrderStatus.id_for(:completed)
  end

  def partially_completed?
    self.id == PaymentOrderStatus.id_for(:partially_completed)
  end

  def failed?
    self.id == PaymentOrderStatus.id_for(:failed)
  end

  def scheduled?
    self.id == PaymentOrderStatus.id_for(:scheduled)
  end

end
