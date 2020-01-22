class Transcriber::Receipts::Index < Transcriber::Base

  attr_accessor :receipts, :companies, :sort_by, :sort_order

  class Transcriber::Receipts::Index::TranscriberPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receipts, :categories, :companies, :users, :paginated_receipts

    # scopes for filters
    has_scope :filter_user

    def init
      self.receipts = params[:receipts]
      self.receipts = apply_scopes(receipts, params)
      self.paginated_receipts = self.receipts.paginate(page: params[:page], per_page: params[:per_page] || 30 )
    end

  end

  def pre_validate
    super()
  end

  def init
    id = params[:company_id] || params[:filter_company_id]
    if id.present?
      self.companies = Company.ocr_enabled.with_id(id)
    else
      self.companies = Company.ocr_enabled
    end
    self.receipts = []
    self.sort_by = params[:sort_by] || 'id'
    self.sort_order = params[:sort_order] || 'desc'
  end

  def authorize

  end

  def process
    user_ids = []
    if params[:filter_parent] == '1'
      self.receipts = Receipt.untranscribed.joins(:user => [:company])
                          .where('companies.id IN (?)', companies.pluck(:id))
                          .reorder("receipts.#{self.sort_by} #{self.sort_order}")
    elsif params[:filter_parent] == '2'
      self.receipts = Receipt.joins(:user => [:company,:expenses])
                          .where('companies.id IN (?)',companies.pluck(:id))
                          .where(expenses:{transcribed: true})
                          .where(expenses:{expense_status_id: ExpenseStatus.ids_for([:unreported, :unsubmitted, :rejected])})
                          .reorder(Arel.sql("expenses.updated_at  #{self.sort_order}"))
    end
  end


  def success
    params[:receipts] = receipts
    Transcriber::Receipts::Index::TranscriberPresenter.new(user, params, messages)
  end
end