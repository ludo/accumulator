class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.references :sprint, :null => false
      t.string :scrumworks_id, :null => false
      t.string :title, :null => false
      t.integer :complexity, :null => false
      t.date :completed_on
      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :stories
  end
end
