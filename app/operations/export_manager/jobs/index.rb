class ExportManager::Jobs::Index < BaseOperation
  attr_accessor :export_jobs

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.export_jobs = user.export_jobs
  end

  def success
    ExportManager::Jobs::Index::SuccessPresenter.new(user, params.merge({export_jobs: self.export_jobs}), messages)
  end

  class ExportManager::Jobs::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :export_jobs, :paginated_export_jobs

    has_scope :filter_name
    has_scope :filter_ids, type: :array
    has_scope :filter_creation_date, using: [:from, :to], type: :hash

    def init
      # if params[:filter_ids]
      #   params[:filter_ids] = params[:filter_ids].first.split(",")
      # end


      self.export_jobs = params[:export_jobs].created_after(7.days.ago).includes(:status)
      self.export_jobs = apply_scopes(self.export_jobs, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_export_jobs = self.export_jobs.paginate(page: page, per_page: per_page)
    end

  end

end