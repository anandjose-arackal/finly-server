class Agreements::AgreementAuthorizer::Index < Agreements::AgreementAuthorizer::Base
  attr_accessor :agreements, :email_authorizations

  def init
    token = params[:token]

    self.email_authorizations = EmailAuthorization.with_token(token).with_valid
    unless email_authorizations.present?
      add_message :error, 'Invalid/Expired Token'
      return
    else
      self.agreements = ::Agreement.with_id(email_authorizations.pluck(:authorizable_id))
    end
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
      agreement_by_type = []
      AgreementType.all.each do |type|
        agreement = self.agreements.with_type_id(type.id)&.first
        content = nil
        content_path = agreement&.file&.path
        if content_path.present?
          content = File.read(content_path)
        end
        agreement_by_type << {
            type: {
                id: type.id,
                name: type.name.humanize
            },
            content: content,
            version: agreement&.version,
            updated_on: DateUtils.date_formatted(agreement&.updated_at),
            url: agreement&.url
        }
      end
      agreement_by_type
    end

  end
end