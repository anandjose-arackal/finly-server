# == Schema Information
#
# Table name: accounting_system_configurations
#
#  id                :integer          not null, primary key
#  company_id        :integer          not null
#  enabled           :boolean          default(FALSE)
#  accounting_system :string(255)
#  options           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountingSystemConfiguration < ApplicationRecord
  belongs_to :company, optional: true

  serialize :options
end
