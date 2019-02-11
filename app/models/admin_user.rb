# == Schema Information
#
# Table name: admin_users
#
#  id                        :integer          not null, primary key
#  email                     :string(255)      default(""), not null
#  encrypted_password        :string(255)      default(""), not null
#  reset_password_token      :string(255)
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  first_name                :string(255)
#  last_name                 :string(255)
#  mobile_number             :string(255)      not null
#  encrypted_master_password :string(255)
#

require 'bcrypt'
class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :admin_user_role_mappings, dependent: :destroy
  has_many :admin_user_roles, through: :admin_user_role_mappings, dependent: :destroy

  accepts_nested_attributes_for :admin_user_role_mappings

  validates :mobile_number, presence: true, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}, uniqueness: true

  scope :with_id, ->(id) { where id: id }
  scope :with_email, ->(email) { where email: email }

  def finly_admin?
    # todo temporary, will change once roles has been estabilished
    return true
    # self.admin_user_role_mappings.finly_admin.present?
  end

  def admin?
    self.admin_user_role_mappings.admin.present?
  end

  def verifier?
    self.admin_user_role_mappings.verifier.present?
  end

  def itzcash_verifier?
    self.admin_user_role_mappings.itzcash_verifier.present?
  end

  def itzcash_operations?
    self.admin_user_role_mappings.itzcash_operations.present?
  end

  def transcriber?
    self.admin_user_role_mappings.transcriber.present?
  end

  def call_center?
    self.admin_user_role_mappings.call_center.present?
  end

  # overriding devise's default method so that it compares against both email and phone number to authenticate
  def self.find_for_database_authentication(conditions={})
    find_by(email: conditions[:username])
  end

  def has_role?(role_id)
    roles = admin_user_roles
    return false unless role_id.present? and roles.present?
    roles.pluck(:id).include?(role_id)
  end

  def name
    return nil if first_name.blank? and last_name.blank?
    name = first_name
    "#{name} #{last_name}"
  end

  def set_master_password(password)
    return unless self.admin? and password.present?
    self.update(encrypted_master_password: BCrypt::Password.create(password))
  end

  def valid_master_password?(password)
    return false unless self.admin? and password.present? and self.encrypted_master_password.present?
    hashed_password = BCrypt::Password.new self.encrypted_master_password
    (hashed_password == password)
  end
end
