class UserSerializer < ActiveModel::Serializer
  attributes :username, :beenz, :token, :photo_url, :created_at

  def include_token?
    current_user == object
  end

  # Output formatted json sample of this object for use in documentation
  def self.to_documentation(name, args = {})
    opts = {
      indentation: 0,
      beenz: nil,
      include_token: false,
      include_photo: true
    }.merge(args)

    spacing = "    #{'  '*opts[:indentation]}"
"{
#{spacing}  \"username\": \"#{name}\",
#{spacing}  \"beenz\": #{opts[:beenz] || [1 + rand(5) + ((rand(2) == 1 ? 0.5 : 0)), 5].min}, # float of #{name}'s beenz#{opts[:include_token] ? "\n#{spacing}  \"token\": \"#{SecureRandom.hex}\", # string if current user is #{name}" : ''}
#{spacing}  \"photo_url\": #{opts[:include_photo] && rand(2) == 1 ? "\"http://somephotourl.com/#{name}.jpg\"" : 'null'}, # string if available
#{spacing}  \"created_at\": #{time_rand.to_json}
#{spacing}}"
  end

  def self.time_rand(from = Time.new(2014, 1, 1), to = Time.now)
    Time.at(from + rand * (to.to_f - from.to_f))
  end
end
