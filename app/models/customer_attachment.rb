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

class CustomerAttachment < ActiveRecord::Base
  belongs_to :customer
end
