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
#

class PaymentFileConfiguration < ApplicationRecord
  belongs_to :company, optional: true

  validates :company_id, presence: true
  validates :file_format, inclusion: {in: PaymentFiles::Config.available_keys}
  
  serialize :options, Hash

end
