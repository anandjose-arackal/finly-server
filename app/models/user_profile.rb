# == Schema Information
#
# Table name: user_profiles
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  kyc_verified           :boolean
#  gcm_sender_id          :string(255)
#  employee_id            :string(255)
#  payroll_id             :string(255)
#  default_currency_id    :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  date_of_birth          :date
#  gender                 :string(255)
#  address_1              :string(255)
#  address_2              :string(255)
#  city                   :string(255)
#  state_id               :integer
#  pin_code               :string(255)
#  signature_file_name    :string(255)
#  signature_content_type :string(255)
#  signature_file_size    :integer
#  signature_updated_at   :datetime
#  signature_title        :string(255)
#

class UserProfile < ApplicationRecord
  include Attachable
  belongs_to :user, optional: true
  belongs_to :default_currency, optional: true, class_name: 'Currency'
  belongs_to :state, optional: true

  has_attached_file :avatar, styles: {large: '2160x2160>', normal: '1080x1080>', thumb: '500x500>'}


  has_attached_file :signature, styles: lambda { |a| a.instance.style_format(a) }
  validates_attachment :signature, content_type: {
      # content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)
      content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  # validates :user_id, presence: true
  # validates :date_of_birth, presence: true
  validates :gender, format: Constants::VALID_GENDER, length: {is: 1}, allow_blank: true
  validates :address_1, length: {maximum: 100}, allow_blank: true
  validates :address_2, length: {maximum: 100}, allow_blank: true
  validates :city, length: {maximum: 100}, allow_blank: true
  # validates :state_id, presence: true
  validates :pin_code, format: Constants::VALID_PIN_CODE, allow_blank: true

  def state_name
    State.name_from_id(self.state_id)
  end

  def gender_name
    case self.gender
      when 'f'
        return "Female"
      when 'm'
        return "Male"
      else
        # nothing to do, ha!
    end
  end

  def salutation_status
    return nil if self.gender.blank?
    case self.gender
      when 'f'
        return 'Mrs'
      when 'm'
        return 'Mr'
      else
        return nil
    end
  end

  def full_address
    address = ""
    address += self.address_1 ? self.address_1 : ''

    address += self.address_2 ? (", " + self.address_2) : ''
    address += self.city ? (", " + self.city) : ''
    address += self.state&.name ? (", " + self.state&.name) : ''
    address += self.pin_code ? (", " + self.pin_code) : ''
    # address += ", " + (self.city || "")
    # address += ", " + (self.state&.name || "")
    # address += ", " + (self.pin_code || "")

    address
  end


end
