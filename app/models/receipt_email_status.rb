# == Schema Information
#
# Table name: receipt_email_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReceiptEmailStatus < ApplicationRecord
  include Seedable

  VALUES = {
      awaiting_processing: 1,
      in_progress: 2,
      completed: 3
  }

  scope :with_name, ->(name) { where name: name }

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count == ReceiptEmailStatus.count
    VALUES.each do |key, value|
      if ReceiptEmailStatus.with_name(key).blank?
        ReceiptEmailStatus.create id: value, name: key
      end
    end
  end

end
