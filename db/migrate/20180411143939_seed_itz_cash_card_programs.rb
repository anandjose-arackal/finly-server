class SeedItzCashCardPrograms < ActiveRecord::Migration
  def change
    ItzCashCardProgram.seed_data
  end
end
