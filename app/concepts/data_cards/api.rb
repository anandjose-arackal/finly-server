# DataCards::API is the base class used for building DataCard JSON
# The goal of the API is to build a JSON response in the following format:
# {
#   "icon": "", # Icon which shows up at the top of the card
#   "tag": "",
#   "title": "",
#   "sub_title": "",
#   "status": {
#     "value": "Approved",
#     "format": "success/failure/warning/info"
#   },
#   "details": [
#     {
#       "icon": "",
#       "label": "",
#       "value": ""
#     }
#   ]
# }
# 
class DataCards::API < Transactions::API

  TYPES ||= ["title", "subtitle", "status", "body"].freeze

  schema do
    params do
      required(:id).filled
      required(:route).filled
    end
  end

  step :init
  step :validate
  step :build
  step :build_result

  def init(context, params:, **)
    # Initialize DataCards::Builder
    context[:builder] = DataCards::Builder.new
    
    true
  end

  # Used for running any validations in sub-classes
  def validate(context, **)
    true
  end

  def build(context, builder:, **)
    # TODO in the inheriting classes
    false
  end

  def build_result(context, builder:, **)
    context[:result] = builder.as_json

    true
  end

  def defaults
    {
      header: {
        icon: ""
      }
    }
  end

end