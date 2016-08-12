# == Schema Information
#
# Table name: user_profiles
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  kyc_verified        :boolean
#  gcm_sender_id       :string(255)
#  employee_id         :integer
#  payroll_id          :integer
#  default_currency_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  mobile_verified     :boolean          default(TRUE), not null
#

class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :default_currency, class_name: "Currency"

  has_attached_file :avatar, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"}

  validates :user_id, presence: true

end
