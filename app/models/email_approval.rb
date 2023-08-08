#  t.string "approval_uuid"
# t.datetime "deleted_at"
# t.integer "company_id"
# t.datetime "created_at", precision: 6, null: false
# t.datetime "updated_at", precision: 6, null: false
# t.string "documentable_type"
# t.bigint "documentable_id"


class EmailApproval < ApplicationRecord
  belongs_to :documentable, polymorphic: true

  def self.generate_email_approval(document_id, document_type_class)
    new_approval = self.new(approval_uuid: SecureRandom.uuid, documentable_id: document_id, documentable_type: EmailApprovalDocumentType.name_for(document_type_class))
    new_approval.save!
    new_approval
  end

  def self.create_for_purachse_request(document)
    EmailApproval.create!(approval_uuid: SecureRandom.uuid, documentable: document)
  end

  def self.delete_email_approval(document_id)
    email_approvals = self.where(documentable_id: document_id)
    email_approvals.each do |ea|
      ea.delete
    end
  end

end