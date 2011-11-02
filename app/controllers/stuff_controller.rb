class StuffController < ApplicationController
  load_and_authorize_resource
  # GET /stuff
  # GET /stuff.xml
  def index
    @stuff = Stuff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  # GET /stuff/1
  # GET /stuff/1.xml
  def show
    @stuff = Stuff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  # GET /stuff/new
  # GET /stuff/new.xml
  def new
    @stuff = Stuff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stuff }
    end
  end

  # GET /stuff/1/edit
  def edit
    @stuff = Stuff.find(params[:id])
  end

  # POST /stuff
  # POST /stuff.xml
  def create
    @stuff = Stuff.new(params[:stuff])

    respond_to do |format|
      if @stuff.save
        format.html { redirect_to(@stuff, :notice => 'Stuff was successfully created.') }
        format.xml  { render :xml => @stuff, :status => :created, :location => @stuff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stuff/1
  # PUT /stuff/1.xml
  def update
    @stuff = Stuff.find(params[:id])

    respond_to do |format|
      if @stuff.update_attributes(params[:stuff])
        format.html { redirect_to(@stuff, :notice => 'Stuff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stuff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stuff/1
  # DELETE /stuff/1.xml
  def destroy
    @stuff = Stuff.find(params[:id])
    @stuff.destroy

    respond_to do |format|
      format.html { redirect_to(stuff_index_url) }
      format.xml  { head :ok }
    end
  end
end
