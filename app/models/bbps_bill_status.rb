class BbpsBillStatus < ApplicationRecord
  include Seedable

  def self.values
    %i( open awaiting_approval retracted rejected approved auto_approved payment_ticket_created payment_initiated failed paid voided )
  end
end
