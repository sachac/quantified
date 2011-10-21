require 'test_helper'

class CsaFoodsControllerTest < ActionController::TestCase
  setup do
    @csa_food = csa_foods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:csa_foods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create csa_food" do
    assert_difference('CsaFood.count') do
      post :create, :csa_food => @csa_food.attributes
    end

    assert_redirected_to csa_food_path(assigns(:csa_food))
  end

  test "should show csa_food" do
    get :show, :id => @csa_food.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @csa_food.to_param
    assert_response :success
  end

  test "should update csa_food" do
    put :update, :id => @csa_food.to_param, :csa_food => @csa_food.attributes
    assert_redirected_to csa_food_path(assigns(:csa_food))
  end

  test "should destroy csa_food" do
    assert_difference('CsaFood.count', -1) do
      delete :destroy, :id => @csa_food.to_param
    end

    assert_redirected_to csa_foods_path
  end
end
