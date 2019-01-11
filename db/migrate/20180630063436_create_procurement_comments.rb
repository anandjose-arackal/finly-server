class CreateProcurementComments < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_comments do |t|
      t.text :body
      t.references :user, index: true, foreign_key: true
      t.references :parent_commentable, polymorphic: true, index: {name: 'indx_prcurmnt_cmments_on_prnt_cmmentble_typ_n_prnt_cmmentble_id'}

      t.timestamps null: false
    end
  end
end
