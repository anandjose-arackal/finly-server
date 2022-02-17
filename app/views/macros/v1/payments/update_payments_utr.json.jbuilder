if @op.success?
  json.data @op[:success]
else
  json.data @op[:error]
end
