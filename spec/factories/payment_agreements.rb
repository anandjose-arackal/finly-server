# == Schema Information
#
# Table name: payment_agreements
#
#  id                    :bigint           not null, primary key
#  order_number          :string(255)
#  title                 :string(255)
#  policy_id             :integer
#  agreement_date        :datetime
#  execution_date        :datetime
#  expiration_date       :datetime
#  renewal_date          :datetime
#  note                  :text(65535)
#  no_expiration         :boolean          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  creator_id            :integer
#  controlling_level_id  :integer
#  status_id             :integer
#  submitted_at          :datetime
#  approved_at           :datetime
#  reject_note           :text(65535)
#  company_id            :integer
#  renewal_reminder_date :datetime
#  total_amount_id       :integer
#  override_order_number :string(255)
#  terminated_at         :datetime
#  terminated_by_id      :integer
#  termination_reason    :text(65535)
#  deleted_at            :datetime
#  revision_of_pa_id     :integer
#  revision_reason       :text(65535)
#  revised_by_id         :integer
#

FactoryBot.define do
  factory :payment_agreement do
    order_number { "MyString" }
    title { "MyString" }
    policy_id { 1 }
    agreement_date { "2019-05-15 17:19:18" }
    execution_date { "2019-05-15 17:19:18" }
    expiration_date { "2019-05-15 17:19:18" }
    renewal_date { "2019-05-15 17:19:18" }
    note { "MyText" }
    no_expiration { false }
  end
end
