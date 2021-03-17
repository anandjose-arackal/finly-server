# == Schema Information
#
# Table name: ml_models
#
#  id              :bigint           not null, primary key
#  company_id      :integer          not null
#  type            :string(255)      not null
#  config          :text(4294967295)
#  built_at        :datetime
#  build_schedule  :string(255)
#  track_schedule  :string(255)
#  build_duration  :integer
#  tracked_at      :datetime
#  algorithm       :string(255)
#  target_key      :string(255)      not null
#  target_key_type :string(255)      not null
#  split_key       :string(255)
#  split_key_type  :string(255)
#  model_klass     :string(255)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  form_id         :string(255)
#  parent_id       :string(255)
#  parent_type     :string(255)
#  pmml            :text(4294967295)
#

require 'rails_helper'

RSpec.describe MlModel::Monitor, type: :model do

  let(:company) { create :company }
  let(:user) { create :vp_user, company: company }
  let(:policy) { create :policy, company: company }
  let(:vendor) { create :yes_bank_vendor, company: company }
  let(:document_1) { create :invoice, created_by: user, company: company, vendor: vendor, policy: policy, submitted_at: 1.year.ago }
  let(:document_2) { create :invoice, created_by: user, company: company, vendor: vendor, policy: policy, submitted_at: 1.month.ago }
  let(:document_3) { create :invoice, created_by: user, company: company, vendor: vendor, policy: nil, submitted_at: 1.month.ago }
  let(:document_4) { create :invoice, created_by: user, company: company, vendor: nil, policy: policy, submitted_at: 1.month.ago }
  let(:document_5) { create :invoice, created_by: user, company: company, vendor: vendor, policy: policy, submitted_at: nil }
  let(:initialize_documents) {
    document_1
    document_2
    document_3
    document_4
    document_5
  }

  let(:valid_data) {
    {
      company_id: company.id,
      config: { fields: [{ name: 'vendor_id', type: 'category' }, { name: 'created_by_id', type: 'category', value: '{{record.created_by_id}}' }] },
      model_klass: "Invoice",
      build_schedule: 'weekly',
      target_key: 'policy_id',
      target_key_type: 'category',
      split_key: 'submitted_at',
      split_key_type: 'datetime',
      algorithm: 'naive_bayes',
    }
  }
  let(:ml_model) { create :ml_model_monitor, company: company }

  context '#create' do

    it 'persists when valid' do
      model = MlModel::Monitor.new valid_data
      expect(model.valid?).to be_truthy
      expect(model.save).to be_truthy
    end

    it 'requires company_id' do
      model = MlModel::Monitor.new valid_data.merge(company_id: nil)
      expect(model.valid?).to be_falsy
    end

    it 'requires config[:fields] to be present' do
      model = MlModel::Monitor.new valid_data.merge(config: nil)
      expect(model.valid?).to be_falsy
    end

    it 'requires model_klass' do
      model = MlModel::Monitor.new valid_data.merge(model_klass: nil)
      expect(model.valid?).to be_falsy
    end

    it 'requires target_key and target_key_type' do
      model = MlModel::Monitor.new valid_data.merge(target_key: nil)
      expect(model.valid?).to be_falsy

      model = MlModel::Monitor.new valid_data.merge(target_key_type: nil)
      expect(model.valid?).to be_falsy
    end

    it 'requires split_key and split_key_type' do
      model = MlModel::Monitor.new valid_data.merge(split_key: nil)
      expect(model.valid?).to be_falsy

      model = MlModel::Monitor.new valid_data.merge(split_key_type: nil)
      expect(model.valid?).to be_falsy
    end

    it 'requires build_schedule' do
      model = MlModel::Monitor.new valid_data.merge(build_schedule: nil)
      expect(model.valid?).to be_falsy
    end

  end

  context '#prepare' do

    before do
      initialize_documents
    end

    it 'should have target_key, split_key and fields in the dataset' do
      data = ml_model.prepare_data
      expect(data.first.has_key?('vendor_id')).to be_truthy
      expect(data.first['vendor_id'].present?).to be_truthy
      expect(data.first.has_key?('created_by_id')).to be_truthy
      expect(data.first['created_by_id'].present?).to be_truthy
      expect(data.first.has_key?('submitted_at')).to be_truthy
      expect(data.first['submitted_at'].present?).to be_truthy
      expect(data.first.has_key?('policy_id')).to be_truthy
      expect(data.first['policy_id'].present?).to be_truthy
    end

    it 'should prepare for invoices which have submitted_at' do
      data = ml_model.prepare_data
      expect(data.count).to eq(4)
    end

    context '#after' do

      it 'should prepare for invoices submitted after the specified date' do
        data = ml_model.prepare_data(after: (1.month.ago - 10.days))
        expect(data.count).to eq(3)
      end

    end
  end

  context '#build' do

    it 'should skip if the data for building is blank' do
      expect(ml_model.model.blank?).to be_truthy
      expect(ml_model.pmml.blank?).to be_truthy

      expect(ml_model.build_model).to be_falsy

      expect(ml_model.model.blank?).to be_truthy
      expect(ml_model.pmml.blank?).to be_truthy
    end

    it 'should build and persist the model' do
      # Initialize the documents
      initialize_documents

      expect(ml_model.model.blank?).to be_truthy
      expect(ml_model.pmml.blank?).to be_truthy

      expect(ml_model.build_model).to be_truthy

      expect(ml_model.model.present?).to be_truthy
      expect(ml_model.pmml.present?).to be_truthy
    end

  end

  context '#predict' do

    before do
      initialize_documents
    end

    it 'should predict the values based on the data' do
      expect(ml_model.build_model).to be_truthy
      expect(ml_model.predict(vendor_id: vendor.id, created_by_id: user.id)).to eq(policy.id.to_s)
    end

  end

  context '#track' do

    before do
      initialize_documents
      expect(ml_model.build_model).to be_truthy
    end

    it 'should update tracked_at' do
      expect(ml_model.tracked_at.nil?).to be_truthy
      ml_model.track_predictions
      expect(ml_model.tracked_at.present?).to be_truthy
    end

    it 'should create a new model if the prediction for the record does not exist' do
      ml_model.update(built_at: (1.month.ago - 10.days))

      old_predictions = MlModelPrediction.count
      expect(ml_model.track_predictions).to be_truthy
      expect(MlModelPrediction.count - old_predictions).to eq(3)
    end

    it 'should update the existing model if the prediction for the record exists' do
      ml_model.update(built_at: (1.month.ago - 10.days))

      expect(ml_model.track_predictions).to be_truthy
      old_predictions = MlModelPrediction.count
      expect(MlModelPrediction.count).to eq(3)
      document_1.update(updated_at: DateTime.now)
      expect(ml_model.track_predictions).to be_truthy
      expect(MlModelPrediction.count - old_predictions).to eq(0)
    end

    it 'should capture the actual value and predicted value for all records' do
      ml_model.update(built_at: (1.month.ago - 10.days))
      expect(ml_model.track_predictions).to be_truthy
      MlModelPrediction.all.each do |prediction|
        if prediction.record.send(ml_model.target_key).present?
          expect(prediction.actual_value.present?).to be_truthy
        end
        expect(prediction.predicted_value.present?).to be_truthy
        expect(prediction.is_accurate_prediction).to eq(prediction.predicted_value == prediction.actual_value)
      end
    end

    it 'should find all records (invoices) which were submitted after the last build time' do
      ml_model.update(built_at: (1.year.ago - 10.days))
      expect(ml_model.track_predictions).to be_truthy
      expect(MlModelPrediction.all.count).to eq(4)

      MlModelPrediction.destroy_all
      ml_model.update(built_at: (1.month.ago - 10.days))
      expect(ml_model.track_predictions).to be_truthy
      expect(MlModelPrediction.all.count).to eq(3)

      MlModelPrediction.destroy_all
      ml_model.update(built_at: DateTime.now)
      expect(ml_model.track_predictions).to be_truthy
      expect(MlModelPrediction.all.count).to eq(0)
    end

  end

end
