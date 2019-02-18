FactoryBot.define do
  factory :user_device do
    user_id { 1 }
    company_id { 1 }
    fingerprint { "MyString" }
    otp_verified { false }
    otp { "MyString" }
    otp_sent_at { "2019-02-18 08:56:28" }
    otp_verified_at { "2019-02-18 08:56:28" }
    otp_count { 1 }
    otp_failed_attempts { 1 }
  end
end
