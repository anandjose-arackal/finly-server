# == Schema Information
#
# Table name: payment_order_attachments
#
#  id                         :integer          not null, primary key
#  attached_file_file_name    :string(255)
#  attached_file_content_type :string(255)
#  attached_file_file_size    :integer
#  attached_file_updated_at   :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  payment_order_id           :integer
#  description                :text(65535)
#  uploader_id                :integer
#

class PaymentOrderAttachment < ApplicationRecord
  include Attachable

  belongs_to :payment_order, optional: true

  CONTENT_TYPES = {content_type: []}

  has_attached_file :attached_file, styles: lambda {|a| a.instance.style_format(a)}, default_url: '/assets/:style/missing.png'

  # has_attached_file :attached_file, styles: {
  #         :thumb => ["500x500>", :png],
  #         :normal => ["1080x1080>", :png],
  #         :large => ["2160x2160>", :png]
  #     }, default_url: '/assets/:style/missing.png'
  validates_attachment :attached_file, content_type: CONTENT_TYPES

end