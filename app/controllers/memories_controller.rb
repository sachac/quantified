class MemoriesController < ApplicationController
  # GET /memories
  # GET /memories.xml
  def index
    authorize! :view_memories, current_account
    @memories = current_account.memories
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @memories }
    end
  end

  # GET /memories/1
  # GET /memories/1.xml
  def show
    @memory = Memory.find(params[:id])
    authorize! :view, @memory

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @memory }
    end
  end

  # GET /memories/new
  # GET /memories/new.xml
  def new
    authorize! :create, Memory
    @memory = Memory.new
    @memory.access = 'public'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @memory }
    end
  end

  # GET /memories/1/edit
  def edit
    @memory = Memory.find(params[:id])
    authorize! :update, @memory
  end

  # POST /memories
  # POST /memories.xml
  def create
    @memory = Memory.new(params[:memory])
    authorize! :create, Memory
    @memory.user = current_account

    respond_to do |format|
      if @memory.save
        format.html { redirect_to(memories_path, :notice => 'Memory was successfully created.') }
        format.xml  { render :xml => @memory, :status => :created, :location => @memory }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @memory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memories/1
  # PUT /memories/1.xml
  def update
    @memory = Memory.find(params[:id])
    authorize! :update, @memory

    respond_to do |format|
      if @memory.update_attributes(params[:memory])
        format.html { redirect_to(memories_path, :notice => 'Memory was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @memory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memories/1
  # DELETE /memories/1.xml
  def destroy
    @memory = Memory.find(params[:id])
    authorize! :delete, @memory
    @memory.destroy

    respond_to do |format|
      format.html { redirect_to(memories_url) }
      format.xml  { head :ok }
    end
  end
end
