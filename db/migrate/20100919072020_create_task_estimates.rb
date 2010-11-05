class CreateTaskEstimates < ActiveRecord::Migration
  def self.up
    create_table :task_estimates do |t|
      t.references :task, :null => false
      t.date :value_on, :null => false
      t.integer :value, :null => false
      t.timestamps :null => false
    end
  end

  def self.down
    drop_table :task_estimates
  end
end
