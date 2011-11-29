class CreateMemories < ActiveRecord::Migration
  def self.up
    create_table :memories do |t|
      t.string :name
      t.text :body
      t.string :access
      t.integer :user_id
      t.timestamps
    end
    create_table :links do |t|
      t.references :link_a, :polymorphic => true
      t.references :link_b, :polymorphic => true
      t.text :data
      t.integer :user_id
      t.timestamps
    end
    add_index :links, [:link_a_id, :link_a_type]
    add_index :links, [:link_b_id, :link_b_type]
    add_index :links, :user_id
    add_index :memories, :user_id
    add_index :memories, :name
  end

  def self.down
    drop_table :memories
    drop_table :links
  end
end
