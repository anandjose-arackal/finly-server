class CreditNoteStatusSeed < ActiveRecord::Migration[5.2]
  def change
    CreditNoteStatus.seed_data
  end
end
