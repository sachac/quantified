class GoalsController < ApplicationController
  # GET /goals
  # GET /goals.json
  def index
    authorize! :manage_account, current_account
    @goals = current_account.goals
    @goal_summary = Goal.check_goals(current_account)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @goals }
    end
  end

  # GET /goals/1
  # GET /goals/1.json
  def show
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @goal }
    end
  end

  # GET /goals/new
  # GET /goals/new.json
  def new
    authorize! :manage_account, current_account
    @goal = current_account.goals.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @goal }
    end
  end

  # GET /goals/1/edit
  def edit
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
  end

  # POST /goals
  # POST /goals.json
  def create
    authorize! :manage_account, current_account
    @goal = current_account.goals.new(params[:goal])

    respond_to do |format|
      if @goal.save
        format.html { redirect_to @goal, :notice => 'Goal was successfully created.' }
        format.json { render :json => @goal, :status => :created, :location => @goal }
      else
        format.html { render :action => "new" }
        format.json { render :json => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /goals/1
  # PUT /goals/1.json
  def update
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])

    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        format.html { redirect_to @goal, :notice => 'Goal was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @goal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /goals/1
  # DELETE /goals/1.json
  def destroy
    authorize! :manage_account, current_account
    @goal = current_account.goals.find(params[:id])
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to goals_url }
      format.json { head :ok }
    end
  end
end
