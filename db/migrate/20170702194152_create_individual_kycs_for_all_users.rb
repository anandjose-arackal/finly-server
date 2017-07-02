class CreateIndividualKycsForAllUsers < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.build_individual_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save
    end
  end
end
