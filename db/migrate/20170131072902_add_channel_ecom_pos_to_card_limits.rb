class AddChannelEcomPosToCardLimits < ActiveRecord::Migration
  def change
    add_column :card_limits, :channel_ecom_pos, :boolean
  end
end
