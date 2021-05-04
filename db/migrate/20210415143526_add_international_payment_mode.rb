class AddInternationalPaymentMode < ActiveRecord::Migration[6.0]
  def change
    TransferMode.create({name: 'International Payment' })
  end
end
