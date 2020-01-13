class CreateSingleSignOnConfigurations < ActiveRecord::Migration[5.2]
  def change
    # for now only creating the attributes that are necessary for SAML. Will add oauth2-specific configurations later
    create_table :single_sign_on_configurations do |t|
      t.integer :company_id, references: "Company", foreign_key: true, index: true
      t.string :assertion_consumer_service_url
      t.string :assertion_consumer_service_binding
      t.string :name_identifier_format
      t.string :issuer
      t.string :idp_sso_target_url
      t.string :idp_cert_fingerprint
      t.string :idp_cert
      t.string :idp_cert_fingerprint_algorithm

      t.timestamps
    end
  end
end
