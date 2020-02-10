class Integrations::Tally::Base < Integrations::Base

  class Integrations::Tally::Base::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end

  end

end