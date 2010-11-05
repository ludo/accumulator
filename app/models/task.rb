class Task < ActiveRecord::Base
  # = Association
  belongs_to :story
  has_many :task_estimates

  # = Validations
  validates_presence_of :scrumworks_id, :title
  validates_uniqueness_of :scrumworks_id
end
