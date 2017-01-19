class MiddlewareFuseServer < ApplicationRecord
  belongs_to :ext_management_system, :foreign_key => 'ems_id'
  has_many :middleware_camel_contexts, :foreign_key => 'fuse_server_id', :dependent => :destroy
  serialize :properties
  acts_as_miq_taggable

  include LiveMetricsMixin

  def metrics_capture
    @metrics_capture ||= ManageIQ::Providers::Hawkular::MiddlewareManager::LiveMetricsCapture.new(self)
  end
end
