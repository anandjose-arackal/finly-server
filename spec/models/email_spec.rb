# == Schema Information
#
# Table name: emails
#
#  id                   :bigint           not null, primary key
#  entity_type          :string(255)
#  entity_id            :bigint
#  company_id           :integer
#  user_id              :integer
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
#  uuid                 :string(36)
#  deleted_at           :datetime
#

require 'rails_helper'

RSpec.describe Email, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
