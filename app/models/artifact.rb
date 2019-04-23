# == Schema Information
#
# Table name: artifacts
#
#  id                      :bigint(8)        not null, primary key
#  resource_id             :integer
#  resource_type           :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer
#  attachment_content_type :string(255)
#  attachment_updated_at   :datetime
#  description             :text(65535)
#  company_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  creator_id              :integer
#

class Artifact < ApplicationRecord
  include Attachable

  belongs_to :resource, optional: true, polymorphic: true
  belongs_to :company, optional: true
  belongs_to :creator,  optional: true, class_name: 'User'

  before_save :add_creator, :add_company

  CONTENT_TYPES = {content_type: []}
  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES

  scope :with_id, -> (ids) { where id: ids }

  def add_creator
    self.creator_id = self.resource.creator_id if self.resource.has_attribute?(:creator_id) && self.resource.creator_id.present?
  end

  def add_company
    self.company_id = self.resource.creator.company_id if self.resource.has_attribute?(:creator_id) && self.resource.creator_id.present?
  end
end
