class UniqueIdentifier < ActiveRecord::Base
  belongs_to :purpose
  belongs_to :company

  scope :with_company_id, ->(id) { where company_id: id }
  scope :with_purpose_id, ->(id) { where purpose_id: id }
end
