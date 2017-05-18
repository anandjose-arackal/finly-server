class ItzCash::GiftCard::Issue < ItzCash::GiftCard::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def query_xml_path
    "#{Rails.root}/app/api_handler/itz_cash/gift_card/issue.xml.erb"
  end

  def query_xml_params
    {

    }
  end

  def success
    create_gift_card
    params[:parsed_response] = self.parsed_response
    ItzCash::GiftCard::Issue::SuccessPresenter.new(user, params, messages)
  end

  class ItzCash::GiftCard::Issue::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :parsed_response, :gift_id

    def init
      self.parsed_response = params[:parsed_response]
      self.gift_id = parsed_response[:VirtualGiftCardResponse][:giftId]
    end

  end

  protected
  def create_gift_card
    param = {
        gift_id: parsed_response[:VirtualGiftCardResponse][:giftId],
    }
    # todo build
  end

end