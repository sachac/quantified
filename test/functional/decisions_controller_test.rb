require 'test_helper'

class DecisionsControllerTest < ActionController::TestCase
  setup do
    @decision = decisions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:decisions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create decision" do
    assert_difference('Decision.count') do
      post :create, :decision => @decision.attributes
    end

    assert_redirected_to decision_path(assigns(:decision))
  end

  test "should show decision" do
    get :show, :id => @decision.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @decision.to_param
    assert_response :success
  end

  test "should update decision" do
    put :update, :id => @decision.to_param, :decision => @decision.attributes
    assert_redirected_to decision_path(assigns(:decision))
  end

  test "should destroy decision" do
    assert_difference('Decision.count', -1) do
      delete :destroy, :id => @decision.to_param
    end

    assert_redirected_to decisions_path
  end
end
