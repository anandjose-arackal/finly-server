class ItzCashDmtBeneficiaryType < ActiveRecord::Base

  validates :name, presence: true

  scope :with_name, ->(name) {where name: name}

  VALUES = {reimbursement_account: 1}

  def self.id_for(key)
    VALUES[key]
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
