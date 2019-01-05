# == Schema Information
#
# Table name: customer_attachments
#
#  id                         :integer          not null, primary key
#  attached_file_file_name    :string(255)
#  attached_file_content_type :string(255)
#  attached_file_file_size    :integer
#  attached_file_updated_at   :datetime
#  customer_id                :integer
#  note                       :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class CustomerAttachment < ApplicationRecord
  include Attachable

  belongs_to :customer, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attached_file, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attached_file, content_type: CONTENT_TYPES
end
