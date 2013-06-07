class DecisionsController < ApplicationController
  # GET /decisions
  # GET /decisions.xml
  def index
    @decisions = current_account.decisions.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @decisions }
    end
  end

  # GET /decisions/1
  # GET /decisions/1.xml
  def show
    @decision = current_account.decisions.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @decision }
    end
  end

  # GET /decisions/new
  # GET /decisions/new.xml
  def new
    @decision = Decision.new
    @decision.date = Time.zone.now.to_date
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @decision }
    end
  end

  # GET /decisions/1/edit
  def edit
    @decision = current_account.decisions.find(params[:id])
  end

  # POST /decisions
  # POST /decisions.xml
  def create
    @decision = current_account.decisions.new(params[:decision])
    @decision.user = current_account
    respond_to do |format|
      if @decision.save
        format.html { redirect_to(@decision, :notice => 'Decision was successfully created.') }
        format.xml  { render :xml => @decision, :status => :created, :location => @decision }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @decision.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /decisions/1
  # PUT /decisions/1.xml
  def update
    @decision = current_account.decisions.find(params[:id])

    respond_to do |format|
      if @decision.update_attributes(params[:decision])
        format.html { redirect_to(@decision, :notice => 'Decision was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @decision.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /decisions/1
  # DELETE /decisions/1.xml
  def destroy
    @decision = current_account.decisions.find(params[:id])
    @decision.destroy

    respond_to do |format|
      format.html { redirect_to(decisions_url) }
      format.xml  { head :ok }
    end
  end
end
