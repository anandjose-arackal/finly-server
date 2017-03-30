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
#  transcribed        :boolean          default(FALSE)
#






class Receipt < ActiveRecord::Base
  belongs_to :parent, polymorphic: true # so that it can be attached to expense as well as report
  belongs_to :user
  belongs_to :receipt_email, dependent: :destroy

  validates :user_id, presence: true

  validates :image, presence: true

  # Reference for adding more file types: http://stackoverflow.com/questions/20920212/generate-thumbnail-from-pdf-in-rails-paperclip
  has_attached_file :image, styles: lambda { |a| a.instance.check_file_type }, #{large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"},
                    default_url: '/assets/:style/missing.png'
  validates_attachment :image, content_type: {
      # content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)
      content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)
  }

  scope :with_user_id, -> (user_ids) {where user_id: user_ids}
  scope :with_id, ->(id) { where id: id }
  scope :without_parent, -> { where(parent_id: nil) }
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    unless date_from.blank? && date_to.blank?
      type_val = :created_at
      date_from = '1990-01-01' if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      receipts = arel_table
      where(receipts[type_val].gteq(date_from).and(receipts[type_val].lteq(date_to)))
    end
  end

  scope :filter_parent, -> (type){
    # 1 - parent absent, 2 - parent present
    case type
      when '1', 1
        where(parent: nil)
      when '2', 2
        where(parent_type: 'Expense')
      else

    end
  }

  scope :filter_user, -> (user_id) {where user_id: user_id}

  scope :untranscribed, -> { where(to_be_transcribed: true) }

  def receipt_file_name
    self.image_file_name
  end

  def is_image?
    self.image_content_type =~ %r(image)
  end

  def is_pdf?
    self.image_file_name =~ %r{\.(pdf)$}i
  end

  def check_file_type
    if self.is_image?
      {
          :thumb => "500x500>",
          large: "2160x2160>",
          normal: "1080x1080>"
      }
    elsif self.is_pdf?
      {
          :thumb => ["500x500>", :png],
          :normal => ["1080x1080>", :png],
          :large => ["2160x2160>", :png]
      }
    else
      {}
    end
  end

  def file_format
    if self.image_content_type == 'application/pdf'
    type = "pdf"
    elsif ["image/jpg", "image/jpeg", "image/png", "image/gif"].include?(self.image_content_type)
      type = "image"
    else
      type = "image"
    end
  end

end
