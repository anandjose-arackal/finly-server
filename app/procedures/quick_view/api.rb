# URL: {{host}}/quick_views?route="forms.vendors"&id=120&tab=default
class QuickView::API < Transactions::API
  include DynamicAttributes

  class_attr :model

  def self.policy(klass = NoObject, action = NoObject)
    @policy = {klass: klass, action: action} unless klass == NoObject
    @policy
  end

  def self.tabs
    @tabs ||= []
  end

  def self.tab(key, label: nil, default: false, builder:)
    config = QuickView::Builders::Tab::Config.new(key: key, label: label, default: default, builder: builder)
    unless config.valid?
      raise "#{self.name}: #{config.errors.full_messages}"
    end
    tabs << config
  end

  schema do
    params do
      required(:route).filled
      required(:id).filled
      optional(:tab)
    end
  end

  step :setup
  step :authorize
  step :post_authorization
  step :build_result

  def setup(context, current_user:, params:, **)
    context[:model] = self.class.model.find_by(id: params[:id])
    return on_error(context, :base, "Record not found") if context[:model].blank?

    context[:exposure] = context[:model].to_exposure

    context[:tab] = self.class.tabs.find {|tab| tab.key.to_s == params[:tab].to_s }
    return on_error(context, :base, "Tab not found") if context[:tab].blank?

    true
  end

  def authorize(context, current_user:, params:, **)
    return true if self.class.policy.blank?

    context[:policy] = self.class.policy[:klass].new(context[:model], current_user)
    return unauthorized! unless context[:policy].send(self.class.policy[:action])

    true
  end

  def post_authorization(context, **)
    true
  end

  def build_config(context, **)
    context[:config] = { tabs: self.class.tabs.as_json }
  end

  def build_result(context, tab:, exposure:, model:, current_user:, **)
    context[:result] = {
      tab.key => tab.builder.render(context, self, current_user, model, exposure, model)
    }.with_indifferent_access
  end

end
