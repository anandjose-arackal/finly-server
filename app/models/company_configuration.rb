# == Schema Information
#
# Table name: company_configurations
#
#  id                               :integer          not null, primary key
#  company_id                       :integer          not null
#  contact_id                       :integer
#  verified                         :boolean          default(FALSE)
#  logo_file_name                   :string(255)
#  logo_content_type                :string(255)
#  logo_file_size                   :integer
#  logo_updated_at                  :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  other_expense_types              :boolean          default(FALSE)
#  encrypted_easy_login_params      :text(65535)
#  registered_mobile_number         :string(255)
#  bank_type                        :string(255)
#  default_card_expense_category_id :integer
#  sso_enabled                      :boolean          default(FALSE)
#  address                          :text(65535)
#

class CompanyConfiguration < ActiveRecord::Base
  belongs_to :company
  belongs_to :default_card_expense_category, class_name: "Category"

  # associating receipt with the particular expense
  has_attached_file :logo, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"}
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  validates :company_id, presence: true, uniqueness: true


end
