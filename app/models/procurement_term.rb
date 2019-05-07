# == Schema Information
#
# Table name: procurement_terms
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :integer
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

class ProcurementTerm < ApplicationRecord
  include SoftDeletable

  belongs_to :company, optional: true

  validates :name, presence: true
  validates :description, presence: true

  scope :with_default, -> {where(default: true)}

  def as_json(options = {})
    {
      id: id,
      name: name,
      description: description,
      default: default
    }
  end
end
