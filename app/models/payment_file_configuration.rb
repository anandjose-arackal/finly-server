# == Schema Information
#
# Table name: payment_file_configurations
#
#  id         :integer          not null, primary key
#  format     :string(255)
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentFileConfiguration < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true
  validates :format, inclusion: {in: PaymentFiles::Config.available_keys}

  serialize :options

end
