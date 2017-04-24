# == Schema Information
#
# Table name: itz_cash_dmt_beneficiary_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ItzCashDmtBeneficiaryType < ActiveRecord::Base

  validates :name, presence: true

  scope :with_name, ->(name) {where name: name}

  VALUES = {reimbursement_account: 1}

  def self.id_for(key)
    VALUES[key]
  end

  def self.name_for(id)
    VALUES.key(id)
  end

  def self.seed_data
    count = ItzCashDmtBeneficiaryType.count
    ItzCashDmtBeneficiaryType::VALUES.each do |key, value|
      if count == 0 or ItzCashDmtBeneficiaryType.with_name(key).blank?
        ItzCashDmtBeneficiaryType.create id: value, name: key
      end
    end
  end

end
