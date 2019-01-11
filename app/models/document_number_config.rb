# == Schema Information
#
# Table name: document_number_configs
#
#  id                             :integer          not null, primary key
#  prefix                         :string(255)
#  sequence_start                 :string(255)
#  company_id                     :integer
#  document_number_config_type_id :integer
#  purpose_id                     :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

class DocumentNumberConfig < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :document_number_config_type, optional: true
  belongs_to :purpose, optional: true

  scope :with_purpose_id, -> (ids) { where purpose_id: ids }
  scope :with_config_type_id, -> (ids) { where document_number_config_type_id: ids }
  scope :with_company_id, -> (ids) {where company_id: ids}
end
