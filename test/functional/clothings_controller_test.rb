require 'test_helper'

class ClothingsControllerTest < ActionController::TestCase
  setup do
    @clothing = clothings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clothings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clothing" do
    assert_difference('Clothing.count') do
      post :create, :clothing => @clothing.attributes
    end

    assert_redirected_to clothing_path(assigns(:clothing))
  end

  test "should show clothing" do
    get :show, :id => @clothing.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @clothing.to_param
    assert_response :success
  end

  test "should update clothing" do
    put :update, :id => @clothing.to_param, :clothing => @clothing.attributes
    assert_redirected_to clothing_path(assigns(:clothing))
  end

  test "should destroy clothing" do
    assert_difference('Clothing.count', -1) do
      delete :destroy, :id => @clothing.to_param
    end

    assert_redirected_to clothings_path
  end
end
