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
#  date_of_birth       :date             not null
#  gender              :string(255)      not null
#  address_1           :string(255)      not null
#  address_2           :string(255)      not null
#  city                :date             not null
#  states_id           :integer          not null
#  pin_code            :string(255)      not null
#

class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :default_currency, class_name: 'Currency'
  belongs_to :state

  has_attached_file :avatar, styles: {large: '2160x2160>', normal: '1080x1080>', thumb: '500x500>'}

  # validates :user_id, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true, format: Constants::VALID_GENDER, length: {is: 1}
  validates :address_1, presence: true, length: {maximum: 100}
  validates :address_2, presence: true, length: {maximum: 100}
  validates :city, presence: true, length: {maximum: 100}
  validates :state_id, presence: true
  validates :pin_code, presence: true, format: Constants::VALID_PIN_CODE

end
