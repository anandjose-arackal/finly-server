class AddConfigToSooConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :single_sign_on_configurations, :type, :string, default: ''
    add_column :single_sign_on_configurations, :logo, :string, default: ''
  end
end
