class Api::Offline::V1::OfflineController < ApplicationController
  layout 'offline'
  respond_to :html, :json
  def track
    authorize! :manage_account, current_account
    @categories = current_account.record_categories.order('full_name').where(:category_type => 'activity')
  end

  def bulk_track
    if !current_user
      respond_to do |format|
        format.html { authorize! :manage_account, current_account and return }
        format.json { authorize! :view_site, User; head :forbidden and return}
      end
    end
    authorize! :manage_account, current_account
    if params[:type] == 'track' || params[:type].nil?
      if params[:record_category_id] and params[:date] and current_account
        cat = current_account.record_categories.find_by_id(params[:record_category_id])
        if cat
          timestamp = (params[:date] =~ /^[0-9]+/) ? Time.at((params[:date].to_i / 1000).to_i).in_time_zone : Time.zone.parse(params[:date]);
          @record = current_account.records.find_by_timestamp(timestamp)
          unless @record
            @record = Record.create(:user => current_account, :timestamp => timestamp, :record_category => cat, :source_name => 'offline')
            data = cat.data
            @record.data ||= Hash.new
            if params[:data]
              params[:data].each do |k, hash|
                if data[hash['name'].to_sym]
                  @record.data[hash['name']] = hash['value']
                end
              end
            end
            @record.save!
          end
          respond_with @record and return
        else
          render :text => "Could not find category", :status => 404 and return
        end
      end
    elsif params[:type] == 'edit'
      if params[:id] and current_account
        record = current_account.records.find_by_id(params[:id])
        data = record.record_category.data
        logger.info params[:data]
        record.data ||= Hash.new
        params[:data].each do |k, hash|
          if data[hash['name'].to_sym]
            record.data[hash['name']] = hash['value']
          end
        end
        record.save!
        respond_with record and return
      end
    end
    render :text => "Error", :status => 500 and return
  end
end
