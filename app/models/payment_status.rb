# == Schema Information
#
# Table name: payment_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentStatus < ActiveRecord::Base

  VALUES = {completed: 1, failed: 2, pending: 3, in_progress: 4, scheduled: 5}

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == PaymentStatus.count
    VALUES.each do |key, value|
      if count == 0 or PaymentStatus.with_name(value).blank?
        PaymentStatus.create id: value, name: key
      end
    end
  end

end
