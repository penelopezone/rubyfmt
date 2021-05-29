def valid?(new_value)
  @Validator.call(new_value)
rescue

  false
end
