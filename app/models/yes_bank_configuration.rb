# == Schema Information
#
# Table name: yes_bank_configurations
#
#  id                   :integer          not null, primary key
#  custom_bank_account  :boolean          default(FALSE)
#  company_id           :integer
#  yes_bank_api_enabled :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class YesBankConfiguration < ApplicationRecord
end
