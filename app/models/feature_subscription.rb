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
#

class FeatureSubscription < ActiveRecord::Base
  belongs_to :subscribable, polymorphic: true

  def cards_enabled
    (gift_card_enabled or gift_voucher_enabled or meal_card_enabled or fuel_card_enabled or medical_card_enabled or expense_card_enabled or reimbursement_card_enabled)
  end

end
