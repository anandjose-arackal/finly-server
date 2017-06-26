# json.multiple_errors @result.formatted_messages
# json.set! :author do
#   json.set! :name, 'David'
# end

# debugger
if @result.formatted_messages
  json.expense_errors @result.formatted_messages.values
end