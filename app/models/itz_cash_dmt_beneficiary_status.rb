# == Schema Information
#
# Table name: itz_cash_dmt_beneficiary_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ItzCashDmtBeneficiaryStatus < ActiveRecord::Base

  validates :name, presence: true

  scope :with_name, ->(name) {where name: name}

  VALUES = {active: 1, disabled: 2}

  def self.id_for(key)
    VALUES[key]
  end

  def self.seed_data
    count = ItzCashDmtBeneficiaryStatus.count
    ItzCashDmtBeneficiaryStatus::VALUES.each do |key, value|
      if count == 0 or ItzCashDmtBeneficiaryStatus.with_name(key).blank?
        ItzCashDmtBeneficiaryStatus.create id: value, name: key
      end
    end
  end

end
