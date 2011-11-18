class ContextsController < ApplicationController
  # GET /contexts
  # GET /contexts.xml
  def index
    @contexts = current_account.contexts.order('name')
    authorize! :view_context, current_account
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contexts }
    end
  end

  # GET /contexts/1
  # GET /contexts/1.xml
  def show
    redirect_to start_context_path(params[:id])
  end

  # GET /contexts/new
  # GET /contexts/new.xml
  def new
    authorize! :create, Context
    @context = Context.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @context }
    end
  end

  # GET /contexts/1/edit
  def edit
    @context = current_account.contexts.find(params[:id])
    authorize! :update, @context
  end

  # POST /contexts
  # POST /contexts.xml
  def create
    authorize! :create, Context
    @context = Context.new(params[:context])
    @context.user = current_account
    respond_to do |format|
      if @context.save
        format.html { redirect_to(@context, :notice => 'Context was successfully created.') }
        format.xml  { render :xml => @context, :status => :created, :location => @context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contexts/1
  # PUT /contexts/1.xml
  def update
    @context = current_account.contexts.find(params[:id])
    authorize! :update, @context
    respond_to do |format|
      if @context.update_attributes(params[:context])
        format.html { redirect_to(@context, :notice => 'Context was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contexts/1
  # DELETE /contexts/1.xml
  def destroy
    @context = Context.find(params[:id])
    authorize! :delete, @context
    @context.destroy

    respond_to do |format|
      format.html { redirect_to(contexts_url) }
      format.xml  { head :ok }
    end
  end

  def start
    # Parse the list of items in this context
    @context = Context.find(params[:id])
    authorize! :start, @context
    @stuff = @context.stuff_rules
    @in_place = Array.new
    @out_of_place = Array.new
    @stuff.each do |name, val|
      if val[:in_place]
        @in_place << name
      else
        @out_of_place << name
      end
    end
  end

  def complete
    @context = Context.find(params[:id])
    authorize! :start, @context
    @stuff = @context.stuff_rules
    @stuff.each do |key, stuff|
      unless stuff[:in_place]
        stuff[:stuff].location = current_account.get_location(stuff[:destination])
        stuff[:stuff].save!
      end
    end
    redirect_to start_context_path(@context)
  end
end
