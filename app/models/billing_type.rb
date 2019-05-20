class BillingType < ApplicationRecord
  include Seedable

    belongs_to :company, optional: true

    def self.values
      [
        :one_time

      ]
    end

    def one_time?
      self.id == BillingType.id_for(:one_time)
    end
end
