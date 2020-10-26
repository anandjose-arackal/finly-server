# == Schema Information
#
# Table name: emails
#
#  id                   :bigint           not null, primary key
#  entity_type          :string(255)
#  entity_id            :bigint
#  company_id           :integer
#  message_id           :string(255)
#  sender               :string(255)
#  recipient            :string(255)
#  bcc                  :string(255)
#  cc                   :string(255)
#  subject              :string(255)
#  body                 :text(4294967295)
#  mailer_klass         :string(255)
#  mailer_action        :string(255)
#  configuration_set    :string(255)
#  sent_at              :datetime
#  delivered_at         :datetime
#  delivery_count       :integer
#  last_opened_at       :datetime
#  open_count           :integer
#  last_link_clicked_at :datetime
#  link_open_count      :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  deleted_at           :datetime
#

class Email < NonTenantedApplicationRecord
  serialize :recipient, JSON

  belongs_to :entity, polymorphic: true, optional: true
  # belongs_to :user
  belongs_to :company, optional: true

  has_many :events, class_name: "EmailEvent"

  scope :order_created_at, -> (type) {reorder created_at: (type.to_sym || :desc)}
end
