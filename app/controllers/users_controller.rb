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
    {
      "username": "abed",
      "beenz": 5,
      "photo_url": "http://somephotourl.com/abed.jpg",
      "created_at": "2014-03-13T05:47:02.284Z"
    }
  EOS
  def show
    u = params[:username].downcase == 'me' ? current_user : User.find_by_username(params[:username])
    raise NotFoundError.new("User not found") unless u
    render :json => u, root: false
  end

  api :POST, '/users', "Create a new user"
  param :username, String, :required => true, :desc => "The desired username"
  param :password, String, :required => true
  error 403, "This username is already taken"
  example <<-EOS
    # The response will look like:
    {
      "username": "jeff",
      "beenz": 1,
      "token": "2309234fe1230d",
      "photo_url": null,
      "created_at": "2014-03-13T05:47:02.284Z"
    }
  EOS
  def create
    raise UnauthorizedError.new("This username is already taken") if params[:username].downcase == "me" || User.find_by_username(params[:username])
    
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
    {
      "username": "jeff",
      "beenz": 1,
      "token": "2309234fe1230d",
      "photo_url": "http://somephotourl.com/jeff.jpg",
      "created_at": "2014-03-13T05:47:02.284Z"
    }
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
    {
      "username": "jeff",
      "beenz": 1,
      "token": "2309234fe1230d",
      "photo_url": "http://somephotourl.com/jeff.jpg",
      "created_at": "2014-03-13T05:47:02.284Z"
    }
  EOS
  def login
    u = User.find_by_username(params[:username])
    raise UnauthorizedError.new("Username not found") unless u
    raise UnauthorizedError.new("Incorrect password") unless u.password == params[:password]

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
    {
      "username": "abed",
      "beenz": 2.5,
      "photo_url": "http://somephotourl.com/abed.jpg",
      "created_at": "2014-03-13T05:47:02.284Z"
    }
  EOS
  def give
    u = User.find_by_username(params[:username])
    current_user.give_beenz_to_user(params[:beenz].to_i, u)

    render json: u, root: false
  end

  api :GET, '/users/notifications', "Get list of notifications for current user"
  param :limit, Integer, :required => false, :desc => "The number of notifications to fetch. Default is 25"
  param_group :token
  example <<-EOS
    # The response will look like:
    [
      {
        "beenz": 4,
        "reviewer": {
          "username": "abed",
          "beenz": 5,
          "photo_url": "http://somephotourl.com/abed.jpg",
          "created_at": "2014-03-10T14:02:45.927Z"
        },
        reviewee: {
          "username": "bubloo",
          "beenz": 3,
          "photo_url": null,
          "created_at": "2014-03-15T23:17:00.760Z"
        }
      },
      {
        "beenz": 1,
        "reviewer": {
          "username": "chang",
          "beenz": 1,
          "photo_url": "http://somephotourl.com/chang.jpg",
          "created_at": "2014-03-10T17:11:20.666Z"
        },
        reviewee: {
          "username": "abed",
          "beenz": 5,
          "photo_url": "http://somephotourl.com/abed.jpg",
          "created_at": "2014-03-10T14:02:45.927Z"
        }
      }
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
      {
        "username": "abed",
        "beenz": 5,
        "photo_url": "http://somephotourl.com/abed.jpg",
        "created_at": "2014-03-10T14:02:45.927Z"
      },
      {
        "username": "annie",
        "beenz": 4,
        "photo_url": null,
        "created_at": "2014-03-13T05:47:02.284Z"
      }
    ]
  EOS
  def search
    u = User.where("LOWER(username) LIKE ?", "%#{params[:query].downcase}%").where.not(id: current_user.id)
    render json: u, root: false
  end
end
