class AddTranscribedToReceipts < ActiveRecord::Migration[4.2]
  def change
    add_column :receipts, :to_be_transcribed, :boolean, default: false
  end
end
