class BeenzValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    !!(value.to_s =~ /^[0-5]$/)
  end

  def self.build(param_description, argument, options, block)
    if argument == 'Beenz'
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}."
  end
end