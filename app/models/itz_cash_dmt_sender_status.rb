# == Schema Information
#
# Table name: itz_cash_dmt_sender_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ItzCashDmtSenderStatus < ApplicationRecord

  VALUES = {active: 1, disabled: 2}

  scope :with_name, ->(name) {where name: name}

  def self.id_for(sym)
    VALUES[sym]
  end

  def name_for(id)
    VALUES.key(id)
  end

  def self.seed_data
    count = ItzCashDmtSenderStatus.count
    VALUES.each do |key, value|
      if count == 0 or ItzCashDmtSenderStatus.with_name(key).blank?
        ItzCashDmtSenderStatus.create id: value, name: key
      end
    end
  end

end
