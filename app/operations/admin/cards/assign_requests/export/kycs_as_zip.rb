class Admin::Cards::AssignRequests::Export::KycsAsZip < Admin::Cards::AssignRequests::Base
  attr_accessor :files

  def init
    if !!params&.dig(:download_all)
      assign_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
      unless assign_requests_presenter.success?
        add_message :error, assign_requests_presenter.messages[:error]
        return
      end
      self.card_assign_requests = assign_requests_presenter.card_assign_requests
      return
    end
    super
  end

  def process
    kycs = IndividualKyc.with_user_id(self.card_assign_requests.pluck(:card_owner_id))
    self.files = []
    kycs&.each do |kyc|
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