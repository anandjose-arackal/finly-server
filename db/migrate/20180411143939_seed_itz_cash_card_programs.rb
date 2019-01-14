class SeedItzCashCardPrograms < ActiveRecord::Migration[4.2]
  def change
    ItzCashCardProgram.seed_data
  end
end
