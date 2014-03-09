class UserSerializer < ActiveModel::Serializer
  attributes :username, :beenz, :token, :photo_url, :beenz_given

  def include_beenz_given?
    !include_token?
  end

  def beenz_given
    object.beenz_received_from_user(current_user)
  end

  def include_token?
    current_user == object
  end
end
