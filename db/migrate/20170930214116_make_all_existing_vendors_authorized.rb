class MakeAllExistingVendorsAuthorized < ActiveRecord::Migration
  def change
    YesBankVendor.update_all(authorized: true)
  end
end
