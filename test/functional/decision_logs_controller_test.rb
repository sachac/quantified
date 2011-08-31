require 'test_helper'

class DecisionLogsControllerTest < ActionController::TestCase
  setup do
    @decision_log = decision_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:decision_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create decision_log" do
    assert_difference('DecisionLog.count') do
      post :create, :decision_log => @decision_log.attributes
    end

    assert_redirected_to decision_log_path(assigns(:decision_log))
  end

  test "should show decision_log" do
    get :show, :id => @decision_log.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @decision_log.to_param
    assert_response :success
  end

  test "should update decision_log" do
    put :update, :id => @decision_log.to_param, :decision_log => @decision_log.attributes
    assert_redirected_to decision_log_path(assigns(:decision_log))
  end

  test "should destroy decision_log" do
    assert_difference('DecisionLog.count', -1) do
      delete :destroy, :id => @decision_log.to_param
    end

    assert_redirected_to decision_logs_path
  end
end
