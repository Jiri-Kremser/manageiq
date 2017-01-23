class MiddlewareCamelContext < ApplicationRecord
  belongs_to :ext_management_system, :foreign_key => 'ems_id'
  belongs_to :middleware_server, :foreign_key => 'server_id'
  has_many :middleware_camel_entities, :foreign_key => 'camel_context_id', :dependent => :destroy
  serialize :properties
  acts_as_miq_taggable

  include LiveMetricsMixin

  def metrics_capture
    @metrics_capture ||= ManageIQ::Providers::Hawkular::MiddlewareManager::LiveMetricsCapture.new(self)
  end
end
