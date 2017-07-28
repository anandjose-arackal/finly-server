class Admin::Cards::AssignRequests::Export::KycsAsZip < Admin::Cards::AssignRequests::Base
  attr_accessor :files

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params&.dig(:card_assign_request_id).blank? and params&.dig(:id).blank? and params&.dig(:card_assign_requests).blank? and not params&.dig(:download_all)
      add_message :error, 'Card Assign Request not found'
    end
  end

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
    exported_excel = Admin::Cards::AssignRequests::Export::AsXls.(user, card_assign_requests: self.card_assign_requests).generate_xls
    self.files << {name: 'new_user_details.xls', file_contents: exported_excel}
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