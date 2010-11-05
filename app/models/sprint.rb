class Sprint < ActiveRecord::Base
  SOAP_NAMESPACE = "http://api.scrumworks.danube.com/ScrumWorks/types"

  # = Associations
  has_many :stories

  # = Validations
  validates_presence_of :ends_on, :name, :scrumworks_id, :starts_on
  validates_uniqueness_of :scrumworks_id

  # = Callbacks

  # = Instance Methods

  # = Class Methods
  class << self

    # Update cache from ScrumWorks and stuff
    def accumulate
      client = Savon::Client.new("http://scrum.kabisa.nl/scrumworks-api/scrumworks")
      client.request.basic_auth("<scrumworks username>", "<scrumworks password>")

      logger.debug("[#{self.class}#accumulate] Fetching products...")
      # TODO What happens when there are multiple products?
      remote_products = client.get_products! do |soap|
        soap.namespace = Sprint::SOAP_NAMESPACE
      end.to_hash[:get_products_response][:result]

      # Hacketyhack! Soap4r might even be an alternative to this weird Savon stuff!
      remote_products = [remote_products] unless remote_products.kind_of?(Array)

      remote_products.each do |remote_product|
        logger.debug("[#{self.class}#accumulate] Fetching sprints...")
        remote_sprints = client.get_sprints! do |soap|
          soap.namespace = Sprint::SOAP_NAMESPACE
          soap.body = { "ProductWSO_1" => remote_product.merge(:order! => [:effort_units, :id, :name]) }
        end.to_hash[:get_sprints_response][:result].delete_if { |s| s[:end_date].to_date < Date.today }

        # Hacketyhack! Soap4r might even be an alternative to this weird Savon stuff!
        remote_sprints = [remote_sprints] unless remote_sprints.kind_of?(Array)

        remote_sprints.each do |remote_sprint|
          logger.debug("[#{self.class}#accumulate] Checking sprint '#{remote_sprint[:id]}'.")

          attrs = {
            :ends_on => remote_sprint[:end_date].to_date,
            :name => remote_sprint[:name],
            :scrumworks_id => remote_sprint[:id],
            :starts_on => remote_sprint[:start_date].to_date
          }

          sprint = Sprint.where(:scrumworks_id => remote_sprint[:id]).first
          sprint ||= if sprint
            logger.debug("[#{self.class}#accumulate] Found existing sprint '#{remote_sprint[:id]}'. Updating...")
            sprint.update_attributes(attrs)
          else
            logger.debug("[#{self.class}#accumulate] Encountered new sprint '#{remote_sprint[:id]}'. Creating...")
            Sprint.create(attrs)
          end

          logger.debug("[#{self.class}#accumulate] Fetching stories for sprint '#{remote_sprint[:id]}'...")
          remote_stories = client.get_active_backlog_items_for_sprint! do |soap|
            soap.namespace = Sprint::SOAP_NAMESPACE
            soap.body = { "SprintWSO_1" => remote_sprint.merge(:order! => [:end_date, :goals, :id, :name, :product_id, :start_date]) }
          end.to_hash[:get_active_backlog_items_for_sprint_response][:result]

          # Hacketyhack! Soap4r might even be an alternative to this weird Savon stuff!
          remote_stories = [remote_stories] unless remote_stories.kind_of?(Array)

          remote_stories.each do |remote_story|
            logger.debug("[#{self.class}#accumulate] Checking story '#{remote_story[:backlog_item_id]}'.")

            attrs = {
              :completed_on => remote_story[:completed_date].try(:to_date),
              :complexity => remote_story[:estimate],
              :scrumworks_id => remote_story[:backlog_item_id],
              :title => remote_story[:title],
            }

            story = sprint.stories.where(:scrumworks_id => remote_story[:backlog_item_id]).first
            story ||= if story
              logger.debug("[#{self.class}#accumulate] Found existing story '#{remote_story[:backlog_item_id]}'. Updating...")
              story.update_attributes(attrs)
            else
              logger.debug("[#{self.class}#accumulate] Encountered new story '#{remote_story[:backlog_item_id]}'. Creating...")
              sprint.stories.create(attrs)
            end

            themes = if remote_story[:themes]
              remote_story[:themes].is_a?(Array) ? remote_story[:themes].collect { |theme| theme.merge(:order! => [:name, :theme_id]) } : remote_story[:themes].merge(:order! => [:name, :theme_id])
            else
              nil
            end

            logger.debug("[#{self.class}#accumulate] Fetching tasks for story '#{remote_story[:backlog_item_id]}'...")
            remote_tasks = client.get_tasks! do |soap|
              soap.namespace = Sprint::SOAP_NAMESPACE
              soap.body = { "BacklogItemWSO_1" => remote_story.merge(:order! => [:active, :backlog_item_id, :completed_date, :description, :estimate, :rank, :release_id, :sprint_id, :themes, :title], :themes => themes) }
            end.to_hash[:get_tasks_response][:result]

            next unless remote_tasks

            # Hacketyhack! Soap4r might even be an alternative to this weird Savon stuff!
            remote_tasks = [remote_tasks] unless remote_tasks.kind_of?(Array)

            remote_tasks.each do |remote_task|
              logger.debug("[#{self.class}#accumulate] Checking task '#{remote_task[:id]}'.")

              attrs = {
                :scrumworks_id => remote_task[:id],
                :title => remote_task[:title]
              }

              task = story.tasks.where(:scrumworks_id => remote_task[:id]).first
              task ||= if task
                logger.debug("[#{self.class}#accumulate] Found existing task '#{remote_task[:id]}'. Updating...")
                task.update_attributes(attrs)
              else
                logger.debug("[#{self.class}#accumulate] Encountered new task '#{remote_task[:id]}'. Creating...")
                story.tasks.create(attrs)
              end

              logger.debug("[#{self.class}#accumulate] Fetching task estimates for task '#{remote_task[:id]}'...")
              remote_task_estimates = client.get_task_estimates! do |soap|
                soap.namespace = Sprint::SOAP_NAMESPACE
                soap.body = { "TaskWSO_1" => remote_task.merge(:order! => [:backlog_item_id, :description, :estimated_hours, :id, :point_person, :rank, :status, :title]) }
              end.to_hash[:get_task_estimates_response][:result]

              # Hacketyhack! Soap4r might even be an alternative to this weird Savon stuff!
              remote_task_estimates = [remote_task_estimates] unless remote_task_estimates.kind_of?(Array)

              remote_task_estimates.each do |remote_task_estimate|
                attrs = {
                  :value => remote_task_estimate[:estimate],
                  :value_on => remote_task_estimate[:estimate_date].to_date
                }

                task_estimate = task.task_estimates.where(:value_on => attrs[:value_on]).first
                task_estimate ||= if task_estimate
                  task_estimate.update_attributes(attrs)
                else
                  task.task_estimates.create(attrs)
                end
              end
            end
          end
        end
      end
    end

  end
end
