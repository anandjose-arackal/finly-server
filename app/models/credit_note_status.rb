# == Schema Information
#
# Table name: credit_note_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CreditNoteStatus < ApplicationRecord
  include Seedable

  def as_json(options = {})
    {
        id: id,
        name: name,
        display_name: name.split("_").map(&:capitalize).join(" ")
    }
  end

  def self.values
    %w( draft retracted awaiting_approval rejected approved auto_approved partially_adjusted adjusted voided unadjusted )
  end

  def display_name
    self.name&.split("_").map(&:capitalize).join(" ")
  end

  def draft?
    self.id == CreditNoteStatus.id_for(:draft)
  end

  def retracted?
    self.id == CreditNoteStatus.id_for(:retracted)
  end

  def rejected?
    self.id == CreditNoteStatus.id_for(:rejected)
  end

  def awaiting_approval?
    self.id == CreditNoteStatus.id_for(:awaiting_approval)
  end

  def approved?
    self.id == CreditNoteStatus.id_for(:approved)
  end

  def auto_approved?
    self.id == CreditNoteStatus.id_for(:auto_approved)
  end

  def voided?
    self.id == CreditNoteStatus.id_for(:voided)
  end

  def partially_adjusted?
    self.id == CreditNoteStatus.id_for(:partially_adjusted)
  end

  def adjusted?
    self.id == CreditNoteStatus.id_for(:adjusted)
  end
end
