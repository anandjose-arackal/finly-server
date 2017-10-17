# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id             :integer          not null, primary key
#  account_number :string(255)
#  ifsc           :string(255)
#  description    :text(65535)
#  parent_id      :integer
#  parent_type    :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class VirtualBankAccount < ActiveRecord::Base
end
