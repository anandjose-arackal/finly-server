class UpdateTotalAmountInBills < ActiveRecord::Migration[5.2]
  def change
    BbpsBill.all.each(&:save)
  end
end
