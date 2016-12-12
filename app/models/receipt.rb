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
#  receipt_email_id   :integer
#





class Receipt < ActiveRecord::Base
  belongs_to :parent, polymorphic: true # so that it can be attached to expense as well as report
  belongs_to :user
  belongs_to :receipt_email

  validates :user_id, presence: true

  validates :image, presence: true

  # validate :validate_expense_user

  has_attached_file :image, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"},
    default_url: "/assets/:style/missing.png"
  validates_attachment :image, content_type: {
      content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)
  }

  scope :with_id, ->(id) { where id: id }
  scope :without_parent, -> { where(parent_id: nil) }
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    unless date_from.blank? && date_to.blank?
      type_val = :created_at
      date_from = "1990-01-01" if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      receipts = arel_table
      where(receipts[type_val].gteq(date_from).and(receipts[type_val].lteq(date_to)))
    end
  end

  def receipt_file_name
    self.image_file_name
  end

  def belongs_to?(user)
    user.receipts.find_by(id: self.id)
  end

  private


  # def validate_expense_user
  #   if self.user && self.parent
  #     if self.user.id != self.parent.user.id
  #       errors.add(:base, "Parent expense does not belong to current user.")
  #     end
  #   end
  # end

end
