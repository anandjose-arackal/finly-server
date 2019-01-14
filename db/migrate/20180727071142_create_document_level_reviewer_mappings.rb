class CreateDocumentLevelReviewerMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :document_level_reviewer_mappings do |t|
      t.references :policy, index: true, foreign_key: true
      t.integer :level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.integer :reviewer_id, references: 'User', foreign_key: true, index: true
      # index name was exceeding 64 chars, to custom name has been given
      t.references :document_reviewer_mappable, polymorphic: true, index: {name: 'indx_doc_lvl_rvwr_mpng_on_doc_rvwr_mpble_tp_n_doc_rvwr_mpble_id'}, null: false
      t.timestamps null: false
    end
  end
end
