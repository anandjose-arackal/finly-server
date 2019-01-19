# == Schema Information
#
# Table name: tax_rates
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  rate        :decimal(20, 5)
#  internal_id :string(255)
#  company_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

class TaxRate < ActiveRecord::Base
  include SoftDeletable
  belongs_to :company

  scope :with_name, -> (name) {where name: name}
  scope :with_rate, -> (rate) {where rate: rate}
  scope :with_internal_id, -> (ids) {where internal_id: ids}

  def as_json
    {
        id: id,
        name: self.name,
        rate: self.rate,
        internal_id: self.internal_id,
    }
  end
end
