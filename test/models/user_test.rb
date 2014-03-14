require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "create user" do
    u = User.new(username: "rawr")
    u.password = "hi"
    assert u.save!
    assert u.password == "hi"
    assert_not u.password == "bye"
    assert_not_nil u.token
    assert_equal(u.score, 0)
    assert_equal(u.weight, 1)
    assert_equal(u.beenz, 1)
    assert u.days_since_creation < 1
    assert_nil u.beenz_given_to_user(users(:bubloo))
    assert_nil u.beenz_received_from_user(users(:bubloo))
  end

  test "find users by username" do
    u = User.find_by_username('BUBloo')
    assert_not_nil u
    assert_equal(u, users(:bubloo))
  end

  test "create duplicate user" do
    u = User.new(username: "BUBloo")
    u.password = "not bubloo"
    assert_raises(ActiveRecord::RecordInvalid) { u.save! }
  end

  test "create user without password" do
    u = User.new(username: "nopass")
    assert_raises(ActiveRecord::RecordInvalid) {u.save!}
  end

  test "create user without username" do
    u = User.new
    u.password = "nouser"
    assert_raises(ActiveRecord::RecordInvalid) {u.save!}
  end

  test "review self" do
    assert_raises(ActiveRecord::RecordInvalid) { users(:bubloo).give_beenz_to_user(4, users(:bubloo)) }
  end

  test "give more than 5 beenz" do
    assert_raises(ActiveRecord::RecordInvalid) { users(:bubloo).give_beenz_to_user(7, users(:abed)) }
  end

  test "give less than 1 beenz" do
    assert_raises(ActiveRecord::RecordInvalid) { users(:bubloo).give_beenz_to_user(0, users(:abed)) }
  end

  test "reviewing another user" do
    assert_equal(users(:abed).beenz, 1)
    assert_nil users(:abed).beenz_received_from_user(users(:bubloo))
    assert_nil users(:bubloo).beenz_given_to_user(users(:abed))
    
    # Review user
    assert_difference('Rating.count') do
      users(:bubloo).give_beenz_to_user(5, users(:abed))
    end
    
    assert_equal(users(:abed).beenz, 2.5)
    assert_equal(users(:abed).score, 5)
    assert_equal(users(:abed).weight, 2)
    assert_equal(users(:abed).beenz_received_from_user(users(:bubloo)), 5)
    assert_equal(users(:bubloo).beenz_given_to_user(users(:abed)), 5)
    assert_nil users(:bubloo).beenz_received_from_user(users(:abed))

    # Review the same user again
    assert_no_difference('Rating.count') do
      users(:bubloo).give_beenz_to_user(3, users(:abed))
    end

    assert_equal(users(:abed).beenz, 1.5)
    assert_equal(users(:abed).score, 3)
    assert_equal(users(:abed).weight, 2)
    assert_equal(users(:abed).beenz_received_from_user(users(:bubloo)), 3)
    assert_equal(users(:bubloo).beenz_given_to_user(users(:abed)), 3)
    assert_nil users(:bubloo).beenz_received_from_user(users(:abed))

    # Receive a review from a different user
    assert_difference('Rating.count') do
      users(:jeff).give_beenz_to_user(5, users(:abed))
    end

    assert_equal(users(:abed).beenz, 4)
    assert_equal(users(:abed).score, 28)
    assert_equal(users(:abed).weight, 7)
    assert_equal(users(:abed).beenz_received_from_user(users(:bubloo)), 3)
    assert_equal(users(:abed).beenz_received_from_user(users(:jeff)), 5)
  end

  test "fetch user ratings" do
    assert_equal(users(:bubloo).notifications.count, 0)
    users(:bubloo).give_beenz_to_user(3, users(:abed))
    assert_equal(users(:bubloo).notifications.count, 1)
    users(:abed).give_beenz_to_user(5, users(:bubloo))
    assert_equal(users(:bubloo).notifications.count, 2)
    assert_equal(users(:bubloo).notifications(1).count, 1)
  end

end
