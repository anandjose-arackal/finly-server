class AddTranscribedToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :to_be_transcribed, :boolean, default: false
  end
end
