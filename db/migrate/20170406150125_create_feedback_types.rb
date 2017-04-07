class CreateFeedbackTypes < ActiveRecord::Migration
  def change
    create_table :feedback_types do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps null: false
    end
    FeedbackType.create_seed_data
  end
end
