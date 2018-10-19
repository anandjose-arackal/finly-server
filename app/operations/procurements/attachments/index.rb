class Procurements::Attachments::Index < Procurements::Attachments::Base
  attr_accessor :attachments

  def init
    self.attachments = user.company.procurement_attachments.orphans
  end

  def process
  end

  def success
    params[:attachments] = self.attachments
    Procurements::Attachments::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Attachments::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachments

    def init
      self.attachments = params[:attachments]
    end
  end

end