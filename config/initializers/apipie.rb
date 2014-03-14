Apipie.configure do |config|
  config.app_name                = "MeowMeowBeenz API"
  config.copyright               = "&copy; #{Date.today.year.to_s} Neil Gupta"
  config.api_base_url            = ""
  config.doc_base_url            = "/docs"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.namespaced_resources    = false

  config.app_info = "
    This is an API for MeowMeowBeenz.
  "
end

# Define custom validators

class IntegerValidator < Apipie::Validator::BaseValidator
  def validate(value)
    !!(value.to_s =~ /^\d+$/)
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description) if argument == Integer
  end

  def description
    "Must be Integer"
  end
end

class BeenzValidator < Apipie::Validator::BaseValidator
  def validate(value)
    !!(value.to_s =~ /^[1-5]$/)
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description) if argument == 'Beenz'
  end

  def description
    "Must be Integer between 1-5."
  end
end