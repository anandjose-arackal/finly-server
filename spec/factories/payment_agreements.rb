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
