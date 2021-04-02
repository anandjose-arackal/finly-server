json.data do
  json.valid_action @op.success?
  if @op[:records][:processable_amount].present?
    json.processable_amount  @op[:records][:processable_amount]
  end
  if @op[:records][:non_processable_amount].present?
    json.non_processable_amount   @op[:records][:non_processable_amount]
  end
  json.records @op[:records]
end