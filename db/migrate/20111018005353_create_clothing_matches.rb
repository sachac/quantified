class CreateClothingMatches < ActiveRecord::Migration
  def self.up
    create_table :clothing_matches, :id => false do |t|
      t.integer :clothing_a_id
      t.integer :clothing_b_id
      t.integer :clothing_log_a_id
      t.integer :clothing_log_b_id
      t.timestamps
    end
    # Set up graphs
    by_date = Hash.new
    ClothingLog.all.each do |l|
      by_date[l.date] ||= Hash.new
      by_date[l.date][l.outfit_id || 1] ||= Array.new
      by_date[l.date][l.outfit_id || 1] << l
    end
    by_date.each do |date, outfits|
      outfits.each do |outfit_id, list|
        0.upto(list.size - 2) do |i|
          a_id = list[i].clothing_id
          (i + 1).upto(list.size - 1) do |j|
            x = ClothingMatch.new(:clothing_a_id => a_id, :clothing_b_id => list[j].clothing_id, :clothing_log_a_id => list[i].id, :clothing_log_b_id => list[j].id)
            x.save
            x = ClothingMatch.new(:clothing_b_id => a_id, :clothing_a_id => list[j].clothing_id, :clothing_log_b_id => list[i].id, :clothing_log_a_id => list[j].id)
            x.save
          end
        end
      end
    end
  end

  def self.down
    drop_table :clothing_matches
  end
end
