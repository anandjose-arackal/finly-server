# frozen_string_literal: true

class AddCompanyIdToMoreModels2 < ActiveRecord::Migration[5.2]
  def change
    add_column :approval_routes, :company_id, :integer, references: 'Company', foreign_key: true, index: true
    add_column :custom_field_attachments, :company_id, :integer, references: 'Company', foreign_key: true, index: true
    add_column :custom_field_selections, :company_id, :integer, references: 'Company', foreign_key: true, index: true
    add_column :export_template_user_role_mappings, :company_id, :integer, references: 'Company', foreign_key: true, index: true
  end
end
