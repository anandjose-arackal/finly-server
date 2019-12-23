# == Schema Information
#
# Table name: itz_cash_properties
#
#  id              :integer          not null, primary key
#  d_code          :string(255)
#  easy_account_no :string(255)
#  company_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ItzCashProperty < ApplicationRecord

  belongs_to :company, optional: true

end
