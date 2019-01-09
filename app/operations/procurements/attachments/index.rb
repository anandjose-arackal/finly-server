class Procurements::Attachments::Index < Procurements::Attachments::Base
  attr_accessor :attachments

  def init
    self.attachments = user.procurement_attachments.orphans
  end

  def process
  end

  def success
    params[:attachments] = self.attachments
    Procurements::Attachments::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Attachments::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachments, :paginated_attachments, :count

    def init
      self.attachments = params[:attachments]
      self.count = self.attachments.count
      self.paginated_attachments = self.attachments.paginate(per_page: params[:per_page], page: params[:page])
    end
  end

end