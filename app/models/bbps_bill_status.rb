# == Schema Information
#
# Table name: bbps_bill_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BbpsBillStatus < ApplicationRecord
  include Seedable

  def self.values
    %i( open awaiting_approval retracted rejected approved auto_approved payment_ticket_created payment_initiated failed paid voided )
  end

  def as_json
    {
        id: id,
        name: name,
        display_name: name.split("_").map(&:capitalize).join(" ")
    }
  end
end
