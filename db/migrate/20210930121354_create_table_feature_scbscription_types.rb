class CreateTableFeatureScbscriptionTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :feature_subscription_types do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps index: true
    end
  end
end
