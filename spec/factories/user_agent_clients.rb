FactoryBot.define do
  factory :user_agent_client do
    user_agent {Faker::Internet.user_agent}
    verification_mode {nil}
    verification_key {nil}
    verification_code_sent_at {nil}
    verified_at {nil}
    verification_code_count {0}
    verification_code_failed_attempts {0}
    status_id {UserAgentClientStatus.id_for(:unverified)}

    factory :user_agent_verified do
      status_id {UserAgentClientStatus.id_for(:verified)}
      verified_at {DateTime.now}
    end

    factory :user_agent_unverified do
      status_id {UserAgentClientStatus.id_for(:unverified)}
    end
  end
end
