class TimelineEventsController < ApplicationController
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
