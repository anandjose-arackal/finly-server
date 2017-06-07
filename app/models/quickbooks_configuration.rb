# == Schema Information
#
# Table name: quickbooks_configurations
#
#  id                         :integer          not null, primary key
#  quickbooks_payment_type    :string(255)
#  user_id                    :integer
#  auto_import                :boolean
#  auto_export                :boolean
#  transaction_date_field     :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  quickbooks_payment_type_id :integer
#

class QuickbooksConfiguration < ActiveRecord::Base
  belongs_to :quickbooks_payment_type
  belongs_to :user
end
