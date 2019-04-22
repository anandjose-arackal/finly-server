# == Schema Information
#
# Table name: attachments
#
#  id                :bigint(8)        not null, primary key
#  resource_id       :integer
#  resource_type     :string(255)
#  file_file_name    :string(255)
#  file_file_size    :decimal(64, 12)
#  file_content_type :string(255)
#  file_updated_at   :datetime
#  company_id        :integer
#  creator_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  description       :text(65535)
#

class Attachment < ApplicationRecord
  include Attachable

  belongs_to :resource, optional: true, polymorphic: true, inverse_of: :resource
  belongs_to :creator, optional: true, class_name: "User"
  belongs_to :company, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :file, content_type: CONTENT_TYPES

  scope :orphans, -> {
    where(resource_id: nil)
  }

  scope :with_ids, -> (ids) {
    where id: ids
  } 

  scope :with_id, -> (ids) { where id: ids }

  def as_json(options={})
    if options[:array]
      [default_json]
    else
      default_json
    end
    
  end

  def default_json
    {
      id: self.id,
      name: self.file_file_name,
      url: self.file&.url,
      created_at: self.created_at.to_date,
      resource_type: self.resource_type,
      resource_id: self.resource_id,
      file_name: self.file.original_filename,
      file_size: (self.file_file_size / 1024).round(2).to_s + " KB",
      status: 'done'
      # created_by: self.creator&.name,
      # description: self.description
    }
  end

  def self.update_resource(options)
    ids = options[:ids]
    resource_id = options[:resource_id]
    user = options[:user]
    if ids.present? && resource_id.present?
      attachments = user.attachments.with_ids(ids).update_all(resource_id: resource_id)
    end
  end
end
