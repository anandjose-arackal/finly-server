# == Schema Information
#
# Table name: receipt_email_templates
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  datetime   :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReceiptEmailTemplate < ActiveRecord::Base
  has_many :receipt_email_senders, dependent: :destroy
  has_many :receipt_email_data_points, dependent: :destroy
end
