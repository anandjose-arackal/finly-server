class AddAgreementIdToUserLoginTracks < ActiveRecord::Migration
  def change
    create_table :user_agreement_tracks do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :agreement, index: true, foreign_key: true, null: false
      t.string :ip_address
      t.string :referrer
      t.string :application

      t.timestamps null: false
    end
    add_column :agreements, :url, :string
  end
end
