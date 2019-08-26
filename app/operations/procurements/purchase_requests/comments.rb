class Procurements::PurchaseRequests::Comments < Procurements::PurchaseRequests::Base

  attr_accessor :comments, :purchase_request

  def process
    self.comments = purchase_request.comments
  end

  def success
    params[:comments] = self.comments
    Procurements::PurchaseRequests::Comments::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Comments::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :comments, :count, :paginated_comments

    def init
      self.comments = params[:comments]
      self.count = self.comments.count
      page = params[:page] || 1
      per_page = params[:per_page] || 30

      self.paginated_comments = self.comments.paginate(page: page, per_page: per_page)
    end

  end

end