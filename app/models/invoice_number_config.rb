# == Schema Information
#
# Table name: invoice_number_configs
#
#  id                            :integer          not null, primary key
#  prefix                        :string(255)      default("")
#  sequence_start                :string(255)
#  company_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  invoice_number_config_type_id :integer
#  purpose_id                    :integer
#

class InvoiceNumberConfig < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :invoice_number_config_type, optional: true
  belongs_to :purpose, optional: true

  scope :with_purpose_id, -> (ids) { where purpose_id: ids }
  scope :with_config_type_id, -> (ids) { where invoice_number_config_type_id: ids }
end
