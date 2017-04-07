class AddTranscribedToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :transcribed, :boolean, default: false
  end
end
