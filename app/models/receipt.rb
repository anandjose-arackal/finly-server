class Receipt < ActiveRecord::Base
  belongs_to :parent, polymorphic: true # so that it can be attached to expense as well as report
  belongs_to :user

  validates :user_id, presence: true

  validates :image, presence: true

  validate :validate_expense_user

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def validate_expense_user
    if self.user && self.parent
      if self.user.id != self.parent.user.id
        errors.add(:base, "Parent expense does not belong to same user as this user.")
      end
    end
  end

  def belongs_to?(user)
    user.receipts.find_by(id: self.id)
  end
end
