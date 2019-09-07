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
