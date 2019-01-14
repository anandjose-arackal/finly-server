class CreateFeedbackTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :feedback_types do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps null: false
    end
    FeedbackType.seed_data
  end
end
