# == Schema Information
#
# Table name: auto_reload_configs
#
#  id                   :integer          not null, primary key
#  minimum_balance_id   :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  enabled              :boolean          default(FALSE)
#  reloadable_id        :integer
#  reloadable_type      :string(255)
#  threshold_balance_id :integer
#  target_balance_id    :integer
#  source_account_id    :integer
#  source_account_type  :string(255)
#  application          :string(255)
#

class AutoReloadConfig < ApplicationRecord

  belongs_to :reloadable, optional: true, polymorphic: true
  belongs_to :minimum_balance, optional: true, class_name: 'Amount'
  belongs_to :threshold_balance, optional: true, class_name: "Amount"
  belongs_to :target_balance, optional: true, class_name: "Amount"
  belongs_to :source_account, optional: true, polymorphic: true

  accepts_nested_attributes_for :minimum_balance
  accepts_nested_attributes_for :threshold_balance
  accepts_nested_attributes_for :target_balance

  # validate :minimum_balance_presence
  validate :source_account_presence

  def minimum_balance_value
    if self.minimum_balance
      return minimum_balance.value
    else
      return 0
    end
  end

  def threshold_balance_value
    if self.threshold_balance
      return threshold_balance.value
    else
      return 0
    end
  end

  def target_balance_value
    if self.target_balance
      return target_balance.value
    else
      return 0
    end
  end

  def source_account_type_id
    case self.source_account_type
      when "UserWallet"
        return 2
      when "ItzCashCompanyAccount"
        return 1
      else
        # do nothing?
    end
  end

  private

  def minimum_balance_presence
    if self.enabled
      unless minimum_balance.present?
        errors.add(:minimum_balance, "cannot be blank")
      end
    end
  end

  def source_account_presence
    if self.enabled
      if source_account.blank?
        errors.add("Source account cannot be blank")
      end
    end
  end
end
