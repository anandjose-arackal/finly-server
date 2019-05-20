# == Schema Information
#
# Table name: payment_terms
#
#  id          :integer          not null, primary key
#  name        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  days_after  :integer
#  description :text(65535)
#  company_id  :integer
#  default     :boolean
#  is_deleted  :boolean          default(FALSE), not null
#  deleted_at  :datetime
#

class PaymentTerm < ApplicationRecord
  include SoftDeletable

  belongs_to :company, optional: true


  # contains the attributes of a few common payment terms
  def self.default_terms
    [
        {
            name: "Net 7",
            days_after: 7,
            description: "Payment seven days after invoice date",
        },
        {
            name: "Net 10",
            days_after: 10,
            description: "Payment 10 days after invoice date"
        },
        {
            name: "Net 30",
            days_after: 30,
            description: "Payment 30 days after invoice date"
        },
        {
            name: "Net 60",
            days_after: 60,
            description: "Payment 60 days after invoice date"
        },
        {
            name: "Net 90",
            days_after: 90,
            description: "Payment 90 days after invoice date"
        },
        {
            name: "EOM",
            description: "Payment to be made by end of month"
        },
        {
            name: "15 MFI",
            description: "Payment to be made on 15th of month following Invoice date"
        },
        {
            name: "21 MFI",
            description: "Payment to be made on 21st of month following Invoice date"
        },
    ]
  end

  # this method seeds the default payment terms for all
  def self.seed_defaults(company_id)
    self.default_terms.each do |val|
      val[:company_id] = company_id
      PaymentTerm.create(val)
    end
  end

  scope :filter_name, -> (name) {
    where("payment_terms.name LIKE ?", "%#{name}%")
  }

  def as_json
    {
      id: self.id, 
      name: self.name, 
      days_after: self.days_after,
      description: self.description,
      default: self.default      
    }
  end
end
