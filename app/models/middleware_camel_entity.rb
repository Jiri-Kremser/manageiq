class MiddlewareCamelEntity < ApplicationRecord
  belongs_to :middleware_camel_context, :foreign_key => 'camel_context_id'
  serialize :properties
  acts_as_miq_taggable

  include LiveMetricsMixin

  def metrics_capture
    @metrics_capture ||= ManageIQ::Providers::Hawkular::MiddlewareManager::LiveMetricsCapture.new(self)
  end
end
