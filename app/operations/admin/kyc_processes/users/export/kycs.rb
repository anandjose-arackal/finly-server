class Admin::KycProcesses::Users::Export::Kycs < Admin::KycProcesses::Users::Base
  attr_accessor :download_urls

  def process
    self.download_urls = []
    self.individual_kycs&.each do |kyc|
      self.download_urls << "www.finly.io#{kyc.kyc_file_1.url}" if kyc.kyc_file_1.present?
      self.download_urls << "www.finly.io#{kyc.kyc_file_2.url}" if kyc.kyc_file_2.present?
    end
  end

  def success
    params[:download_urls] = self.download_urls
    Admin::KycProcesses::Users::Export::Kycs::SuccessPresenter.new(user, params, messages)
  end

  class Admin::KycProcesses::Users::Export::Kycs::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :download_urls

    def init
      self.download_urls = params[:download_urls]
    end

  end

end