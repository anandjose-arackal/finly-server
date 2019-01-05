class AddSequenceNumberToFieldConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :sequence_number, :integer, index: true
  end
end
