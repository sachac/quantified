require 'test_helper'

class LocationHistoriesControllerTest < ActionController::TestCase
  setup do
    @location_history = location_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_history" do
    assert_difference('LocationHistory.count') do
      post :create, :location_history => @location_history.attributes
    end

    assert_redirected_to location_history_path(assigns(:location_history))
  end

  test "should show location_history" do
    get :show, :id => @location_history.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @location_history.to_param
    assert_response :success
  end

  test "should update location_history" do
    put :update, :id => @location_history.to_param, :location_history => @location_history.attributes
    assert_redirected_to location_history_path(assigns(:location_history))
  end

  test "should destroy location_history" do
    assert_difference('LocationHistory.count', -1) do
      delete :destroy, :id => @location_history.to_param
    end

    assert_redirected_to location_histories_path
  end
end
