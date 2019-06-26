# == Schema Information
#
# Table name: icici_bank_company_accounts
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  balance_id :integer
#

require 'rails_helper'

RSpec.describe IciciBankCompanyAccount, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
