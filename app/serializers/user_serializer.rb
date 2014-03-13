class UserSerializer < ActiveModel::Serializer
  attributes :username, :beenz, :token, :photo_url, :created_at

  def include_token?
    current_user == object
  end
end
