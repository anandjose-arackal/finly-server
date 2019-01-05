class MakeAllExistingVendorsAuthorized < ActiveRecord::Migration[4.2]
  def change
    YesBankVendor.update_all(authorized: true)
  end
end
