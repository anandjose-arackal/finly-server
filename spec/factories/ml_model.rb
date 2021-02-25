FactoryBot.define do
  factory :ml_model do

    model_klass { "Invoice" }
    build_schedule { 'weekly' }
    target_key { "policy_id" }
    target_key_type { "category" }
    split_key { "submitted_at" }
    split_key_type { "datetime" }
    algorithm { "naive_bayes" }

    factory :ml_model_monitor, class: 'MlModel::Monitor' do
      type { "MlModel::Monitor" }
      config { { fields: [{ name: 'vendor_id', type: 'category' }, { name: 'created_by_id', type: 'category', value: "{{record.created_by_id}}" }] } }
    end
  end
end
