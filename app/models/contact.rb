class Contact < ActiveRecord::Base
  belongs_to :contactable, polymorphic: true

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # validates_numericality_of :number, allow_nil: true
  validates :email, format: VALID_EMAIL_ADDRESS, uniqueness: {case_sensitive: false}, allow_nil: true
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