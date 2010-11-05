class TaskEstimate < ActiveRecord::Base
  # = Association
  belongs_to :task

  # = Validations
  validates_presence_of :value, :value_on
  validates_uniqueness_of :value_on, :scope => [:task_id]
end
