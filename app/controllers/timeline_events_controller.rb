class TimelineEventsController < ApplicationController
  include TimelineEventsHelper
  # GET /timeline_events
  # GET /timeline_events.json
  def index
    authorize! :manage, User
    @timeline_events = TimelineEvent.order('created_at DESC')
    @timeline_events = @timeline_events.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @timeline_events }
    end
  end

  # GET /timeline_events/1
  # GET /timeline_events/1.json
  def show
    authorize! :manage, User
    @timeline_event = TimelineEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @timeline_event }
    end
  end

  # GET /timeline_events/new
  # GET /timeline_events/new.json
  def new
    authorize! :manage, User
    @timeline_event = TimelineEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @timeline_event }
    end
  end

  # GET /timeline_events/1/edit
  def edit
    authorize! :manage, User
    @timeline_event = TimelineEvent.find(params[:id])
  end

  # POST /timeline_events
  # POST /timeline_events.json
  def create
    authorize! :manage, User
    @timeline_event = TimelineEvent.new(params[:timeline_event])

    respond_to do |format|
      if @timeline_event.save
        format.html { redirect_to @timeline_event, :notice => 'Timeline event was successfully created.' }
        format.json { render :json => @timeline_event, :status => :created, :location => @timeline_event }
      else
        format.html { render :action => "new" }
        format.json { render :json => @timeline_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /timeline_events/1
  # PUT /timeline_events/1.json
  def update
    authorize! :manage, User
    @timeline_event = TimelineEvent.find(params[:id])

    respond_to do |format|
      if @timeline_event.update_attributes(params[:timeline_event])
        format.html { redirect_to @timeline_event, :notice => 'Timeline event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @timeline_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timeline_events/1
  # DELETE /timeline_events/1.json
  def destroy
    authorize! :manage, User
    @timeline_event = TimelineEvent.find(params[:id])
    @timeline_event.destroy

    respond_to do |format|
      format.html { redirect_to timeline_events_url }
      format.json { head :ok }
    end
  end
end
