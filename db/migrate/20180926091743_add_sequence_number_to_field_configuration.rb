class AddSequenceNumberToFieldConfiguration < ActiveRecord::Migration
  def change
    add_column :field_configurations, :sequence_number, :integer, index: true
  end
end
