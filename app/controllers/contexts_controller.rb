class ContextsController < ApplicationController
  # GET /contexts
  # GET /contexts.xml
  def index
    @contexts = Context.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contexts }
    end
  end

  # GET /contexts/1
  # GET /contexts/1.xml
  def show
    @context = Context.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @context }
    end
  end

  # GET /contexts/new
  # GET /contexts/new.xml
  def new
    @context = Context.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @context }
    end
  end

  # GET /contexts/1/edit
  def edit
    @context = Context.find(params[:id])
  end

  # POST /contexts
  # POST /contexts.xml
  def create
    @context = Context.new(params[:context])

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
    @context = Context.find(params[:id])

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
    @context.destroy

    respond_to do |format|
      format.html { redirect_to(contexts_url) }
      format.xml  { head :ok }
    end
  end
end
