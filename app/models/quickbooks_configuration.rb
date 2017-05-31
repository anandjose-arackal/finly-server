# == Schema Information
#
# Table name: quickbooks_configurations
#
#  id                      :integer          not null, primary key
#  quickbooks_payment_type :string(255)
#  payment_type_id         :integer
#  user_id                 :integer
#  auto_import             :boolean
#  auto_export             :boolean
#  transaction_date_field  :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class QuickbooksConfiguration < ActiveRecord::Base
  belongs_to :payment_type
  belongs_to :user
end
