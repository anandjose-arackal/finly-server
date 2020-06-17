class Dashboard::VendorPayments::Base < Dashboard::Base
  class Dashboard::VendorPayments::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    def build_path(id, status_name, status_id, rule: nil)
      params = {
          filter_status: {_id: status_id.to_s, identifier: status_name},
          id: id
      }
      if rule.present?
        filter = rule.as_ransack
        params[:input_filters] = {advanced: [filter[:g][:'0']]}
        params[:q] = filter
      end
      "#{id}/params=#{params.to_json}"
    end
  end
end