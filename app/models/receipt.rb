class Receipt < ActiveRecord::Base
  belongs_to :attachment, polymorphic: true # so that it can be attached to expense as well as report
  belongs_to :user
  #belongs_to :report

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def belongs_to?(user)
    user.receipts.find_by(id: self.id)
  end
end
