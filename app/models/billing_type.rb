# == Schema Information
#
# Table name: billing_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BillingType < ApplicationRecord
  include Seedable

    belongs_to :company, optional: true

    def self.values
      [
        :one_time, :fixed_periodic, :variable_periodic

      ]
    end

    def one_time?
      self.id == BillingType.id_for(:one_time)
    end

    def fixed_periodic?
      self.id == BillingType.id_for(:fixed_periodic)
    end

    def variable_periodic?
      self.id == BillingType.id_for(:variable_periodic)
    end

    def as_json
      {
        id: self.id,
        name: self.name&.titleize,
        key: self.name
      }
    end
end
