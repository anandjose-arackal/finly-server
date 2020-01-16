# == Schema Information
#
# Table name: company_funds_auto_transfer_configs
#
#  id                   :integer          not null, primary key
#  company_id           :integer
#  threshold_amount_id  :integer
#  frequency_name       :string(255)
#  frequency_day        :string(255)
#  amount_transfer_type :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  enabled              :boolean          default(FALSE)
#  transfer_mode        :string(255)
#

class CompanyFundsAutoTransferConfig < ApplicationRecord
  belongs_to :company, optional: true

  belongs_to :threshold_amount, optional: true, class_name: "Amount"

  accepts_nested_attributes_for :threshold_amount

  scope :enabled, -> { where enabled: true }
end
