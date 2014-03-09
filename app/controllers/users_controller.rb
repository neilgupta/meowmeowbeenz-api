class UsersController < ApplicationController
  before_filter :require_token, :except => [:create, :login]

  def_param_group :token do
    param :token, String, :required => true, :desc => "User token"
  end

  api :GET, '/users/:username', "Get details for a user, or get your own details at /users/me"
  param_group :token
  error 404, "User not found"
  def show
    u = params[:username].downcase == 'me' ? current_user : User.find_by_username(params[:username])
    raise NotFoundError.new("User not found") unless u
    render :json => u, root: false
  end

  api :POST, '/users', "Create a new user"
  param :username, String, :required => true, :desc => "The desired username"
  param :password, String, :required => true
  error 403, "This username is already taken"
  def create
    raise UnauthorizedError.new("This username is already taken") if params[:username].downcase == "me" || User.find_by_username(params[:username])
    u = User.new(username: params[:username])
    u.password = params[:password]
    u.save!
    render :json => u, root: false
  end

  api :PUT, '/users/:username', "Update a user's password or upload a photo"
  param :password, String, :desc => "New password for user"
  param_group :token
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
  def login
    u = User.includes(:meows_received).find_by_username(params[:username])
    raise UnauthorizedError.new("Username not found") unless u
    raise UnauthorizedError.new("Incorrect password") unless u.password == params[:password]

    u.generate_token
    u.save!

    render :json => u, root: false
  end

  api :GET, '/users/logout', "Logout as a user"
  param_group :token
  def logout
    current_user.generate_token
    current_user.save!

    head :ok
  end

  api :POST, '/users/:username/give', "Give meowmeowbeenz to a user"
  param :beenz, Integer, :required => true, :desc => "Number of meowmeowbeenz to give user"
  param_group :token
  def give
    u = User.find_by_username(params[:username])
    current_user.give_beenz_to_user(params[:beenz], u)

    render json: u, root: false
  end

  api :GET, '/users/search', "Search for users"
  param :query, String, :required => true
  param_group :token
  def search
    u = User.includes(:meows_received).where("LOWER(username) LIKE ?", "%#{params[:query].downcase}%")
    render json: u, root: false
  end
end
