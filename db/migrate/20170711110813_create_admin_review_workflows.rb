class CreateAdminReviewWorkflows < ActiveRecord::Migration[4.2]
  def change
    create_table :admin_review_workflows do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
  end
end
