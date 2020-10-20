# == Schema Information
#
# Table name: billing_accounts
#
#  id         :bigint           not null, primary key
#  balance_id :integer
#  company_id :integer
#  enabled    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

# RSpec.describe BillingAccount, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
# end
