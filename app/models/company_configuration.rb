# == Schema Information
#
# Table name: company_configurations
#
#  id                :integer          not null, primary key
#  company_id        :integer          not null
#  contact_id        :integer
#  verified          :boolean          default(FALSE)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#


class CompanyConfiguration < ActiveRecord::Base
  belongs_to :company

  # associating receipt with the particular expense
  has_attached_file :logo, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"}

  validates :company_id, presence: true, uniqueness: true

end
