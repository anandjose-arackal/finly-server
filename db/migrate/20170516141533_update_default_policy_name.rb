class UpdateDefaultPolicyName < ActiveRecord::Migration[4.2]
  def change
    Policy.unscoped.default.update_all(name: "Company (Default)") if Policy.all.count > 0
  end
end
