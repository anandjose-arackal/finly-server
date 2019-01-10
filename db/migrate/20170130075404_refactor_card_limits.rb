class RefactorCardLimits < ActiveRecord::Migration[4.2]
  def change
    create_table :channel_types do |t|
      t.string :name
      t.string :abbreviation
    end

    add_column :card_limits, :limit_type_id, :integer, references: "ChannelType", foreign_key: true, index: true
  end
end
