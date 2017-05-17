class UpdateDefaultPolicyName < ActiveRecord::Migration
  def change
    Policy.default.update_all(name: "Company (Default)") if Policy.all.count > 0
  end
end
