class GoalsController < ApplicationController
  respond_to :html, :xml, :json, :csv

  # GET /goals
  # GET /goals.json
  def index
    authorize! :manage_account, current_account
    @goals = current_account.goals
    @goal_summary = Goal.check_goals(current_account)
    if request.format.csv?
      respond_with @goals
    else
      respond_with({ :goals => @goals, :goal_summary => @goal_summary.values })
    end
  end

  # GET /goals/1
  # GET /goals/1.json
  def show
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    respond_with @goal
  end

  # GET /goals/new
  # GET /goals/new.json
  def new
    authorize! :manage_account, current_account
    @goal = current_account.goals.new
    respond_with @goal
  end

  # GET /goals/1/edit
  def edit
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    respond_with @goal
  end

  # POST /goals
  # POST /goals.json
  def create
    authorize! :manage_account, current_account
    @goal = current_account.goals.new(params[:goal])
    add_flash :notice, 'Goal was successfully created.' if @goal.save 
    respond_with @goal
  end

  # PUT /goals/1
  # PUT /goals/1.json
  def update
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    add_flash :notice, 'Goal was successfully updated.' if @goal.update_attributes(params[:goal])
    respond_with @goal
  end

  # DELETE /goals/1
  # DELETE /goals/1.json
  def destroy
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    @goal.destroy
    respond_with @goal, :location => goals_url
  end
end
