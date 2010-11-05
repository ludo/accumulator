class CreateSprints < ActiveRecord::Migration
  def self.up
    create_table :sprints do |t|
      t.string :scrumworks_id, :null => false
      t.string :name, :null => false
      t.date :starts_on, :null => false
      t.date :ends_on, :null => false
      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :sprints
  end
end
