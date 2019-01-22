class ChangeNilForCardProgram < ActiveRecord::Migration[4.2]
  def change
    change_column_null :cards, :card_program_id, true
  end
end
