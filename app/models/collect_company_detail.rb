# == Schema Information
#
# Table name: collect_company_details
#
#  id                        :integer          not null, primary key
#  gst                       :string(255)
#  pan                       :string(255)
#  company_id                :integer
#  company_logo_file_name    :string(255)
#  company_logo_content_type :string(255)
#  company_logo_file_size    :integer
#  company_logo_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  address                   :text(65535)
#  pin                       :text(65535)
#

class CollectCompanyDetail < ApplicationRecord
  include Attachable

  belongs_to :company, optional: true

  has_many :company_branches

  has_attached_file :company_logo, styles: lambda { |a| a.instance.check_file_type(a) },
                    default_url: '/assets/:style/missing.png'
  validates_attachment :company_logo, content_type: {
      content_type: %w(image/jpg image/jpeg image/png image/gif)
  }
end
