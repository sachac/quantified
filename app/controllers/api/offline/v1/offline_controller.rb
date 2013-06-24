class Api::Offline::V1::OfflineController < ApplicationController
  layout 'offline'
  respond_to :html, :json
  def track
    authorize! :manage_account, current_account
    @categories = current_account.record_categories.order('full_name').where(:category_type => 'activity')
  end

  def bulk_track
    if !current_user
      authorize! :manage_account, current_account
    end
    authorize! :manage_account, current_account
    if params[:type] == 'track' || params[:type].nil?
      if params[:record_category_id] and params[:date] and current_account
        cat = current_account.record_categories.find_by_id(params[:record_category_id])
        if cat
          data = cat.data
          timestamp = (params[:date] =~ /^[0-9]+/) ? Time.at((params[:date].to_i / 1000).to_i).in_time_zone : Time.zone.parse(params[:date]);
          @record = current_account.records.find_by_timestamp(timestamp)
          if @record
            @record.record_category_id = cat.id
          else
            @record = current_account.records.create(timestamp: timestamp, record_category: cat, source_name: 'offline')
          end
          if params[:data]
            params[:data].each do |k, hash|
              @record.set_data(hash['name'], hash['value'])
            end
          end
          @record.save
          respond_with @record and return
        else
          render :text => I18n.t('offline.category_not_found'), :status => 404 and return
        end
      end
    elsif params[:type] == 'edit'
      if params[:id] and current_account
        record = current_account.records.find_by_id(params[:id])
        data = record.record_category.data
        if params[:data]
          record.data = Hash.new
          params[:data].each do |k, hash|
            record.set_data(hash['name'], hash['value'])
          end
        end
        record.save!
        respond_with record and return
      end
    end
    render :text => "Error", :status => 500 and return
  end
end
