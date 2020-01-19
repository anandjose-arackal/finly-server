# == Schema Information
#
# Table name: icici_bank_company_accounts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  balance_id :integer
#  enabled    :boolean          default(FALSE)
#  uuid       :string(36)
#

require 'rails_helper'

RSpec.describe IciciBankCompanyAccount, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
