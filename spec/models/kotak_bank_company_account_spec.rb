# == Schema Information
#
# Table name: kotak_bank_company_accounts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  balance_id :integer
#  enabled    :boolean          default(FALSE)
#  uuid       :string(36)
#  deleted_at :datetime
#

require 'rails_helper'

RSpec.describe KotakBankCompanyAccount, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
