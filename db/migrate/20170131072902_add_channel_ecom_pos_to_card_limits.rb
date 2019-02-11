class AddChannelEcomPosToCardLimits < ActiveRecord::Migration[4.2]
  def change
    add_column :card_limits, :channel_ecom_pos, :boolean
  end
end
