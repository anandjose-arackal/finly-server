class AddApplicationToAllNonDefaultPolicies < ActiveRecord::Migration
  def change
    Policy.where(default: false).update_all(application: 'em')
  end
end
