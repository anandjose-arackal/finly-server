# == Schema Information
#
# Table name: bbps_bill_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class BbpsBillStatus < ApplicationRecord
  include Seedable

  def self.values
    %i( open awaiting_approval retracted rejected approved auto_approved payment_ticket_created payment_initiated failed paid voided payment_ticket_deleted)
  end

  def open?
    self.id == BbpsBillStatus.id_for(:open)
  end

  def awaiting_approval?
    self.id == BbpsBillStatus.id_for(:awaiting_approval)
  end

  def retracted?
    self.id == BbpsBillStatus.id_for(:retracted)
  end

  def rejected?
    self.id == BbpsBillStatus.id_for(:rejected)
  end

  def approved?
    self.id == BbpsBillStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == BbpsBillStatus.id_for(:auto_approved)
  end

  def payment_ticket_created?
    self.id == BbpsBillStatus.id_for(:payment_ticket_created)
  end

  def payment_initiated?
    self.id == BbpsBillStatus.id_for(:payment_initiated)
  end

  def payment_ticket_deleted?
    self.id == BbpsBillStatus.id_for(:payment_ticket_deleted)
  end

  def paid?
    self.id == BbpsBillStatus.id_for(:paid)
  end

  def failed?
    self.id == BbpsBillStatus.id_for(:failed)
  end

  def voided?
    self.id == BbpsBillStatus.id_for(:voided)
  end

  def as_json
    {
        id: id,
        name: name,
        display_name: name.split("_").map(&:capitalize).join(" ")
    }
  end
end
