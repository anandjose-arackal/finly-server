class CreateReportComments < ActiveRecord::Migration
  def change
    create_table :report_comments do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.references :report_comment_action, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.references :expense, index: true, foreign_key: true
      t.string :updated_field
      t.text :updated_from
      t.text :updated_to
      t.integer :rejected_to_id, :references => "user", index: true, foreign_key: true
      t.text :content

      t.timestamps null: false
    end
  end
end
