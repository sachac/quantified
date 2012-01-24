class ConvertRecordData < ActiveRecord::Migration
  def up
    RecordCategory.all.each do |r|
      if r.data.is_a? Hash
        r.data = r.data.map { |k,v| {'key' => k.to_s, 'label' => v[:label], 'type' => v[:type] } }
        r.save!
      end
    end
  end

  def down
  end
end
