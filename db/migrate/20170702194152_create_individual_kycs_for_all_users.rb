class CreateIndividualKycsForAllUsers < ActiveRecord::Migration[4.2]
  def change
    User.all.each do |user|
      if user.individual_kyc.nil?
        user.build_individual_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save
      end
    end
  end
end
