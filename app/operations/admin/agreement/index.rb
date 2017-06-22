class Admin::Agreement::Index < Admin::Agreement::Base
  attr_accessor :agreements

  def init
    self.agreements = Agreement.all.active
  end

  def success
    params[:agreements] = self.agreements
    Admin::Agreement::Index::Presenter.new(user, params, messages)
  end

  class Admin::Agreement::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :agreements

    def init
      self.agreements = params[:agreements]
    end

    def agreements_by_type
      agreement_by_type = {}
      AgreementType.all.each do |type|
        agreement = self.agreements.with_type_id(type.id)&.first
        content = nil
        content_path = agreement&.file&.path
        if content_path.present?
          content = File.read(content_path)
        end
        agreement_by_type[type.id] = {
            type: {
                id: type.id,
                name: type.name.humanize
            },
            content: content
        }
      end
      agreement_by_type
    end

  end

end