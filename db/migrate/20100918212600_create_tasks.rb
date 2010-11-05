class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.references :story, :null => false
      t.string :scrumworks_id, :null => false
      t.string :title, :null => false
      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :tasks
  end
end
