# == Schema Information
#
# Table name: receipts
#
#  id                 :integer          not null, primary key
#  expense_id         :integer
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  parent_id          :integer
#  parent_type        :string(255)
#  note               :text(65535)
#

class Receipt < ActiveRecord::Base
  belongs_to :parent, polymorphic: true # so that it can be attached to expense as well as report
  belongs_to :user

  validates :user_id, presence: true

  validates :image, presence: true

  validate :validate_expense_user

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  scope :without_parent, -> {where(parent_id: nil)}

  def receipt_file_name
    self.image_file_name
  end

  def belongs_to?(user)
    user.receipts.find_by(id: self.id)
  end

  private

  def validate_expense_user
    if self.user && self.parent
      if self.user.id != self.parent.user.id
        errors.add(:base, "Parent expense does not belong to current user.")
      end
    end
  end

end
