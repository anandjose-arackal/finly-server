# == Schema Information
#
# Table name: payment_file_configurations
#
#  id          :integer          not null, primary key
#  file_format :string(255)
#  company_id  :integer          not null
#  options     :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  default     :boolean
#

class PaymentFileConfiguration < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true
  validates :file_format, inclusion: {in: [nil, 'custom', 'yes_bank', 'icici_bank', 'karnataka_bank', 'kotak_mahindra_bank', 'hdfc_bank']}

  serialize :options, Hash

end
