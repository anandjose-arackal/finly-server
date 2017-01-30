class RefactorCardLimits < ActiveRecord::Migration
  def change
    create_table :channel_types do |t|
      t.string :name
      t.string :abbreviation
    end

    remove_column :card_limits, :budget
    add_column :card_limits, :budget_id, :integer, references: "Amount", index: true, foreign_key: true
    add_column :card_limits, :limit_type_id, :integer, references: "ChannelType", foreign_key: true, index: true
  end
end
