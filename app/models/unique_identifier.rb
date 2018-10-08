# == Schema Information
#
# Table name: unique_identifiers
#
#  id             :integer          not null, primary key
#  prefix         :string(255)      not null
#  sequence_start :string(255)      not null
#  purpose_id     :integer          not null
#  company_id     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class UniqueIdentifier < ActiveRecord::Base
  belongs_to :purpose
  belongs_to :company

  scope :with_company_id, ->(id) { where company_id: id }
  scope :with_purpose_id, ->(id) { where purpose_id: id }

  validates :purpose, presence: true
  validates :company_id, presence: true
  validates :sequence_start, presence: true

end
