class AddPaymentTypeCreditMealCard < ActiveRecord::Migration
  def change
    if PaymentType.count > 0 and PaymentType.with_name(:credit_meal_card).blank?
      PaymentType.create PaymentType.create(id: PaymentType.id_for(:credit_meal_card), name: :credit_meal_card)
    end
  end
end
