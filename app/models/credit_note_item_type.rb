class CreditNoteItemType < ApplicationRecord
  include Seedable

  def self.values
    %w( qty_change price_drop gst_change qty_change_price_drop qty_change_gst_change price_drop_gst_change qty_change_price_drop_gst_change )
  end

end
