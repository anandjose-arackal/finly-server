# == Schema Information
#
# Table name: credit_note_item_types
#
#  id   :bigint           not null, primary key
#  name :string(255)
#

class CreditNoteItemType < ApplicationRecord
  include Seedable

  def self.values
    %w( qty_change price_drop gst_change qty_change_price_drop qty_change_gst_change price_drop_gst_change qty_change_price_drop_gst_change )
  end

end
