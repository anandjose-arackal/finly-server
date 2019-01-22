class AddApplicationToAllNonDefaultPolicies < ActiveRecord::Migration[4.2]
  def change
    Policy.where(default: false).update_all(application: 'em')
  end
end
