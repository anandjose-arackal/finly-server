# == Schema Information
#
# Table name: feature_subscriptions
#
#  id                         :integer          not null, primary key
#  subscribable_id            :integer          not null
#  subscribable_type          :string(255)      not null
#  ocr_enabled                :boolean          default(FALSE), not null
#  expense_management_enabled :boolean          default(FALSE), not null
#  gift_card_enabled          :boolean          default(FALSE), not null
#  gift_voucher_enabled       :boolean          default(FALSE), not null
#  meal_card_enabled          :boolean          default(FALSE), not null
#  fuel_card_enabled          :boolean          default(FALSE), not null
#  medical_card_enabled       :boolean          default(FALSE), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  expense_card_enabled       :boolean          default(FALSE)
#  reimbursement_card_enabled :boolean          default(FALSE)
#  hard_copy_receipt          :boolean          default(FALSE)
#  itz_cash_d_code_enabled    :boolean          default(FALSE)
#  yes_bank_account           :boolean
#

class FeatureSubscription < ActiveRecord::Base
  belongs_to :subscribable, polymorphic: true

  def cards_enabled
    (gift_card_enabled or gift_voucher_enabled or meal_card_enabled or fuel_card_enabled or medical_card_enabled or expense_card_enabled or reimbursement_card_enabled)
  end

  def d_code_enabled?
    if self.itz_cash_d_code_enabled || self.cards_enabled
      return true
    elsif self.subscribable.itz_cash_property.d_code.present?
      return true
    end
    false
  end

end
