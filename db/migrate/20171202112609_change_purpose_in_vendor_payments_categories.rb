class ChangePurposeInVendorPaymentsCategories < ActiveRecord::Migration[4.2]
  def change
    Category.all.each do |category|
      if category.purpose_id == 2
        category.update(purpose_id: 3)
      end
    end
  end
end
