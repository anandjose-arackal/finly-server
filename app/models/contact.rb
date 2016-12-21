# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  name             :string(255)
#  number           :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contactable_id   :integer
#  contactable_type :string(255)
#  designation      :string(255)
#


class Contact < ActiveRecord::Base
  belongs_to :contactable, polymorphic: true

  # validates_numericality_of :number, allow_nil: true
  validates :email, format: Constants::VALID_EMAIL_FORMAT, uniqueness: {case_sensitive: false}, allow_nil: true
  validates :contactable_id, presence: true
  validates :contactable_type, presence: true
  validate :all_contact_fields_cannot_be_nil

  private
  def all_contact_fields_cannot_be_nil
    if self.email.blank? and self.number.blank?
      errors.add(:email, "or mobile number required to save contact")
    end
  end

end
