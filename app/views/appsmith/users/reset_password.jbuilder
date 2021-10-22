if @op.success? && @op[:error].blank?
  json.data @op[:success]
else
  json.data @op[:error]
end
