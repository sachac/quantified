require 'test_helper'

class ClothingLogsControllerTest < ActionController::TestCase
  setup do
    @clothing_log = clothing_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clothing_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clothing_log" do
    assert_difference('ClothingLog.count') do
      post :create, :clothing_log => @clothing_log.attributes
    end

    assert_redirected_to clothing_log_path(assigns(:clothing_log))
  end

  test "should show clothing_log" do
    get :show, :id => @clothing_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @clothing_log.to_param
    assert_response :success
  end

  test "should update clothing_log" do
    put :update, :id => @clothing_log.to_param, :clothing_log => @clothing_log.attributes
    assert_redirected_to clothing_log_path(assigns(:clothing_log))
  end

  test "should destroy clothing_log" do
    assert_difference('ClothingLog.count', -1) do
      delete :destroy, :id => @clothing_log.to_param
    end

    assert_redirected_to clothing_logs_path
  end
end
