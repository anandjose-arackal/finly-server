class StaticPagesController < BaseControllers::PublicBase
  layout 'static'

  def home
    if logged_in?
      redirect_to home_index_path
    end
  end

  def about

  end

  def tos
    @agreement = get_agreement(:terms_and_conditions)
    render json: @agreement.as_json
  end

  def prepaid_card_agreement
    @agreement = get_agreement(:prepaid_card_agreement)
    render json: @agreement.as_json
  end

  def privacy
    @agreement = get_agreement(:privacy_policy)
    render json: @agreement.as_json
  end

  def bank_transfer_agreement
    @agreement = get_agreement(:bank_transfer_agreement)
    render json: @agreement.as_json
  end

  private

  def get_agreement(type)
    agreement = Agreement.with_type_id(AgreementType.id_for(type)).active.first
    @agreement = {}
    @agreement[:updated_at] = agreement.file_updated_at.strftime "%d %B %Y"
    @agreement[:content] = nil
    content_path = agreement&.file&.url
    if content_path.present?
      @agreement[:content]  = open(content_path).read
    end
    @agreement
  end

end
