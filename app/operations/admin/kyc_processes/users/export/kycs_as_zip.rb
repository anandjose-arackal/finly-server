class Admin::KycProcesses::Users::Export::KycsAsZip < Admin::KycProcesses::Users::Base
  attr_accessor :files

  def init
    if !!params&.dig(:download_all)
      individual_kycs_presenter = Admin::KycProcesses::Users::Index.(user, params)
      unless individual_kycs_presenter.success?
        add_message :error, individual_kycs_presenter.messages[:error]
        return
      end
      self.individual_kycs = individual_kycs_presenter.individual_kycs
      return
    end
    super
  end

  def process
    self.files = []
    self.individual_kycs&.each do |kyc|
      file_name_prefix = "#{kyc.user.id}"
      if kyc.user.cards.present?
        file_name_prefix = "#{kyc.user.cards.first.proxy}"
      end
      self.files << {name: "#{file_name_prefix}_1.jpg", path: kyc.kyc_file_1.path(:normal)} if kyc.kyc_file_1.present?
      self.files << {name: "#{file_name_prefix}_2.jpg", path: kyc.kyc_file_2.path(:normal)} if kyc.kyc_file_2.present?
    end
  end

  def success
    date = Date.today
    Exporter::AsZip.new(user, {filename: "kyc_#{date.day}_#{date.month}_#{date.year}", files: self.files}, messages)
  end

end