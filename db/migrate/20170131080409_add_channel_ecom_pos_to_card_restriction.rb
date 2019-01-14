class AddChannelEcomPosToCardRestriction < ActiveRecord::Migration[4.2]
  def change
    add_column :card_restrictions, :channel_ecom_pos, :boolean
    remove_column :card_limits, :channel_ecom_pos
  end
end
