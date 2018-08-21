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

class AccountingSystemConfiguration < ActiveRecord::Base
  belongs_to :company

  serialize :options
end
