class UsersControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, {'username' => 'Bubloo', 'token' => User.find(2).token}
    assert @response.body =~ /\{"username":"bubloo","beenz":/
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, {'username' => "hippo", 'password' => "monkey"}
    end
   
    assert_response :success
    assert @response.body =~ /\{"username":"hippo","beenz":/
    assert_not_nil User.find_by_username('Hippo')
  end

  test "should login" do
    old_token = User.find(1).token
    post :login, {'username' => "bubloo", 'password' => "hi"}
   
    assert_response :success
    assert @response.body =~ /\{"username":"bubloo","beenz":/
    assert_not_equal(User.find(1).token, old_token)
  end

  test "should logout" do
    old_token = User.find(1).token
    get :logout, {'token' => old_token}
   
    assert_response :success
    assert_not_equal(User.find(1).token, old_token)
  end

  test "should give meowmeowbeenz" do
    old_beenz = User.find(2).beenz

    assert_difference('Rating.count') do
      post :give, {'username' => "abed", 'beenz' => 5, 'token' => User.find(1).token}
    end

    assert_response :success
    assert @response.body =~ /\{"username":"abed","beenz":/
    assert_not_equal(User.find(2).beenz, old_beenz)
  end

  test "should search" do
    get :search, {'query' => "ab", 'token' => User.find(1).token}
    assert @response.body =~ /\[\{"username":"abed","beenz":/
    assert_response :success
  end

end