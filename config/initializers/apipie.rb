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
