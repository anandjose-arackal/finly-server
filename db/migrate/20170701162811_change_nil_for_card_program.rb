class ChangeNilForCardProgram < ActiveRecord::Migration
  def change
    change_column_null :cards, :card_program_id, true
  end
end
