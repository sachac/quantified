class DecisionsController < ApplicationController
  respond_to :html, :json, :xml, :csv
  load_and_authorize_resource

  def index
    respond_with @decisions
  end

  def show
    respond_with @decision
  end

  def new
    @decision.date = Time.zone.now.to_date
    respond_with @decision
  end

  # GET /decisions/1/edit
  def edit
    respond_with @decision
  end

  # POST /decisions
  # POST /decisions.xml
  def create
    @decision.user = current_account
    if @decision.save
      add_flash :notice, I18n.t('decision.created')
    end
    respond_with @decision
  end

  # PUT /decisions/1
  # PUT /decisions/1.xml
  def update
    if @decision.update_attributes(params[:decision])
      add_flash :notice, I18n.t('decision.updated')
    end
    respond_with @decision
  end

  # DELETE /decisions/1
  # DELETE /decisions/1.xml
  def destroy
    @decision.destroy
    respond_to do |format|
      format.html { redirect_to(decisions_url) }
      format.any  { head :ok }
    end
  end
end
