class Api::Offline::V1::OfflineController < ApplicationController
  layout 'offline'
  respond_to :html, :json
  def track
    authorize! :manage_account, current_account
    @categories = current_account.record_categories.order('full_name').where(:category_type => 'activity')
  end

  def bulk_track
    logger.info params[:format]
    if !current_user
      respond_to do |format|
        format.html { authorize! :manage_account, current_account and return }
        format.json { authorize! :view_site, User; head :forbidden and return}
      end
    end
    authorize! :manage_account, current_account
    if params[:record_category_id] and params[:date] and current_account
      cat = current_account.record_categories.find_by_id(params[:record_category_id])
      if cat
        @record = Record.create(:user => current_account, :timestamp => Time.zone.parse(params[:date]), :record_category => cat, :source => 'offline')
        @record.update_previous
        respond_with @record and return
      else
        render :text => "Could not find category", :status => 404 and return
      end
    end
    render :text => "Error", :status => 500 and return
  end
end
