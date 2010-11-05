class Story < ActiveRecord::Base
  # = Association
  belongs_to :sprint
  has_many :tasks

  # = Validations
  validates_presence_of :complexity, :scrumworks_id, :title
  validates_uniqueness_of :scrumworks_id
end
