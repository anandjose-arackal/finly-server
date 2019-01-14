class AddCardProgramMedicalCard < ActiveRecord::Migration[4.2]
  def change
    if CardProgram.count > 0 and Company.count > 0
      CardProgram.seed_data
    end
  end
end
