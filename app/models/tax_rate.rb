# == Schema Information
#
# Table name: tax_rates
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  rate             :decimal(20, 5)
#  internal_id      :string(255)
#  company_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_deleted       :boolean          default(FALSE), not null
#  deleted_at       :datetime
#  cgst             :decimal(10, 5)
#  sgst             :decimal(10, 5)
#  igst             :decimal(10, 5)
#  igst_internal_id :string(255)
#  cgst_internal_id :string(255)
#  sgst_internal_id :string(255)
#

class TaxRate < ApplicationRecord
  include SoftDeletable
  belongs_to :company, optional: true

  validates :rate, presence: true

  scope :with_name, -> (name) {where name: name}
  scope :with_rate, -> (rate) {where rate: rate}
  scope :with_internal_id, -> (ids) {where internal_id: ids}

  after_create do
    self.update(igst: self.rate, cgst: (self.rate / 2), sgst: (self.rate / 2))
  end

  def as_json(options = {})
    {
        id: id,
        name: self.name,
        rate: self.rate,
        cgst: self.cgst,
        sgst: self.sgst,
        igst: self.igst,
        sgst_internal_id: self.sgst_internal_id,
        cgst_internal_id: self.cgst_internal_id,
        igst_internal_id: self.igst_internal_id,
        display_name: "#{self.rate} - #{self.name}"
    }
  end
end
