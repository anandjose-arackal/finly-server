class SeedItzCashCardProgramsAgain < ActiveRecord::Migration[5.2]
  def change
    ItzCashCardProgram.seed_data
  end
end
