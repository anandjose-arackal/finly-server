# == Schema Information
#
# Table name: procurement_attachments
#
#  id                        :integer          not null, primary key
#  file_file_name            :string(255)
#  file_content_type         :string(255)
#  file_file_size            :integer
#  file_updated_at           :datetime
#  name                      :string(255)
#  company_id                :integer
#  description               :text(65535)
#  procurement_document_id   :integer
#  procurement_document_type :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  user_id                   :integer
#

class ProcurementAttachment < ActiveRecord::Base
  include Attachable

  belongs_to :procurement_document, polymorphic: true
  belongs_to :company

  CONTENT_TYPES = {content_type: []}

  has_attached_file :file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :file, content_type: CONTENT_TYPES

  scope :orphans, -> {
    where(procurement_document: nil)
  }

  scope :with_id, -> (ids) { where id: ids }
end
