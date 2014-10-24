class GoalsController < ApplicationController
  respond_to :html, :xml, :json, :csv

  # GET /goals
  # GET /goals.json
  def index
    authorize! :manage_account, current_account
    @goals = current_account.goals
    @goals.each { |x| x.parse }
    if request.format.csv?
      respond_with @goals
    else
      @goal_summary = Goal.check_goals(current_account)
      respond_with({ :goals => @goals, :goal_summary => @goal_summary.values })
    end
  end

  # GET /goals/1
  # GET /goals/1.json
  def show
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    @goal.parse
    respond_with @goal
  end

  # GET /goals/new
  # GET /goals/new.json
  def new
    authorize! :manage_account, current_account
    @goal = current_account.goals.new
    if params[:record_category_id] then
      @goal.record_category = current_account.record_categories.find_by_id(params[:record_category_id])
    end
    respond_with @goal
  end

  # GET /goals/1/edit
  def edit
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    @goal.parse
    respond_with @goal
  end

  # POST /goals
  # POST /goals.json
  def create
    authorize! :manage_account, current_account
    @goal = current_account.goals.new(goal_params)
    @goal.set_from_form(params)
    add_flash :notice, I18n.t('goals.created') if @goal.save
    respond_with @goal, location: goals_path
  end

  # PUT /goals/1
  # PUT /goals/1.json
  def update
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    params[:goal].delete(:user_id)
    result = @goal.update_attributes(goal_params)
    @goal.set_from_form(params)
    add_flash :notice, I18n.t('goals.updated') if @goal.save
    respond_with @goal, location: goals_path
  end

  # DELETE /goals/1
  # DELETE /goals/1.json
  def destroy
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    @goal.destroy
    respond_with @goal, :location => goals_url
  end

  private
  def goal_params
    params.require(:goal).permit(:name, :expression, :record_category, :record_category_id, :period, :label)
  end
end
