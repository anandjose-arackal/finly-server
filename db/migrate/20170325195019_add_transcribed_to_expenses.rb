class AddTranscribedToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :transcribed, :boolean, default: false
  end
end
