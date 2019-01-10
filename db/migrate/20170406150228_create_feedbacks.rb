class CreateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :feedbacks do |t|
      t.references :feedback_type, index: true, foreign_key: true, null: false
      t.text :content, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
