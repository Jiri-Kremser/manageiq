class MiddlewareCamelContext < ApplicationRecord
  belongs_to :middleware_fuse_server, :foreign_key => 'fuse_server_id'
  has_many :middleware_camel_entities, :foreign_key => 'camel_context_id', :dependent => :destroy
  serialize :properties
  acts_as_miq_taggable

  include LiveMetricsMixin

  def metrics_capture
    @metrics_capture ||= ManageIQ::Providers::Hawkular::MiddlewareManager::LiveMetricsCapture.new(self)
  end
end
