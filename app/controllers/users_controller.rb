class UsersController < ApplicationController
  before_filter :require_token, :except => [:create, :login]

  def_param_group :token do
    param :token, String, :required => true, :desc => "User token"
  end

  api :GET, '/users/:username', "Get details for a user, or get your own details at /users/me"
  param_group :token
  error 404, "User not found"
  example <<-EOS
    # The response to /users/abed will look like:
    #{UserSerializer.to_documentation('abed')}
  EOS
  def show
    u = params[:username].downcase == 'me' ? current_user : User.find_by_username(params[:username])
    raise Exceptionally::NotFound.new("User not found") unless u
    render :json => u, root: false
  end

  api :POST, '/users', "Create a new user"
  param :username, String, :required => true, :desc => "The desired username"
  param :password, String, :required => true
  error 403, "This username is already taken"
  example <<-EOS
    # The response will look like:
    #{UserSerializer.to_documentation('jeff', {beenz: 1, include_token: true, include_photo: false})}
  EOS
  def create
    raise Exceptionally::Forbidden.new("This username is already taken") if params[:username].downcase == "me" || User.find_by_username(params[:username])
    
    u = User.new(username: params[:username])
    u.password = params[:password]
    u.save!

    @current_user = u

    render :json => u, root: false
  end

  api :PUT, '/users/:username', "Update a user's password or upload a photo"
  param :password, String, :desc => "New password for user"
  param_group :token
  example <<-EOS
    # The response will look like:
    #{UserSerializer.to_documentation('jeff', {include_token: true})}
  EOS
  def update
    current_user.password = params[:password] if params[:password]
    current_user.photo = params[:photo] if params[:photo]
    current_user.save!

    render :json => current_user, root: false
  end

  api :POST, '/users/login', "Login as a user"
  param :username, String, :required => true
  param :password, String, :required => true
  error 404, "Username not found"
  error 404, "Incorrect password"
  example <<-EOS
    # The response will look like:
    #{UserSerializer.to_documentation('abed', {include_token: true})}
  EOS
  def login
    u = User.find_by_username(params[:username])
    raise Exceptionally::Unauthorized.new("Username not found") unless u
    raise Exceptionally::Unauthorized.new("Incorrect password") unless u.password == params[:password]

    u.generate_token
    u.save!

    @current_user = u

    render :json => u, root: false
  end

  api :GET, '/users/logout', "Logout as a user"
  param_group :token
  description <<-EOS
  Logs the current user out by invalidating the current token. This will return a blank response with status code 200.
  EOS
  def logout
    current_user.generate_token
    current_user.save!

    head :ok
  end

  api :POST, '/users/:username/give', "Give MeowMeowBeenz to this user"
  param :beenz, 'Beenz', :required => true, :desc => "Number of MeowMeowBeenz to give user, must be between 1-5"
  param_group :token
  example <<-EOS
    # The response to /users/abed/give will look like:
    #{UserSerializer.to_documentation('abed')}
  EOS
  def give
    u = User.find_by_username(params[:username])
    current_user.give_beenz_to_user(params[:beenz].to_i, u)

    render json: u, root: false
  end

  api :GET, '/users/notifications', "Get list of notifications for current user"
  param :limit, Integer, :required => false, :desc => "The number of notifications to fetch. Default is 25"
  param_group :token
  description <<-EOS
  Get a list of MeowMeowBeenz given and received by this user. The reviewer gives MeowMeowBeenz to the reviewee.
  To determine if the notification is for giving or receiving, just check if the current user is the reviewer or reviewee.
  EOS
  example <<-EOS
    # The response will look like:
    [
      #{RatingSerializer.to_documentation('abed', 'bubloo', 5, 3.5, {indentation: 1})},
      #{RatingSerializer.to_documentation('chang', 'abed', 1, 5, {indentation: 1})}
    ]
  EOS
  def notifications
    render json: current_user.notifications(params[:limit]), root: false
  end

  api :GET, '/users/search', "Search for users"
  param :query, String, :required => true
  param_group :token
  example <<-EOS
    # The response to /users/search?query=a will look like:
    [
      #{UserSerializer.to_documentation('abed', {indentation: 1})},
      #{UserSerializer.to_documentation('annie', {indentation: 1})},
      #{UserSerializer.to_documentation('britta', {indentation: 1})}
    ]
  EOS
  def search
    u = User.where("LOWER(username) LIKE ?", "%#{params[:query].downcase}%").where.not(id: current_user.id)
    render json: u, root: false
  end
end
