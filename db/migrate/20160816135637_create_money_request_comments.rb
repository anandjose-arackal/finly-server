class CreateMoneyRequestComments < ActiveRecord::Migration
  def change
    create_table :money_request_comment_actions do |t|
      t.string :name

      t.timestamps null: false
    end
    create_table :money_request_comments do |t|
      t.references :money_request, index: true, foreign_key: true, null: false
      t.integer :comment_action_id, references: 'MoneyRequestCommentAction',index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.references :expense, index: true, foreign_key: true
      t.string :updated_field
      t.text :updated_from
      t.text :updated_to
      t.integer :rejected_to_id, :references => 'User', index: true, foreign_key: true
      t.text :content

      t.timestamps null: false
    end
  end
end
