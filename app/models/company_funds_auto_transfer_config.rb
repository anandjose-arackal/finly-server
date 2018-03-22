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
#

class CompanyFundsAutoTransferConfig < ActiveRecord::Base
  belongs_to :company

  belongs_to :threshold_amount, class_name: "Amount"

  accepts_nested_attributes_for :threshold_amount
end
