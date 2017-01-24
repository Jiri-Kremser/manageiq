require_relative 'hawkular_helper'

describe ManageIQ::Providers::Hawkular::MiddlewareManager::MiddlewareCamelContext do

  test_hostname, test_port, the_feed_id = 'localhost', 8080, '8044c162-6682-4076-b2ac-646223e308e2'

  let(:ems_hawkular) do
    # allow(MiqServer).to receive(:my_zone).and_return("default")
    _guid, _server, zone = EvmSpecHelper.create_guid_miq_server_zone

    auth = AuthToken.new(:name     => "test",
                         :auth_key => "valid-token",
                         :userid   => test_userid,
                         :password => test_password)
    FactoryGirl.create(:ems_hawkular,
                       :hostname        => test_hostname,
                       :port            => test_port,
                       :authentications => [auth],
                       :zone            => zone)
  end

  let(:camel_context) do
    FactoryGirl.create(:hawkular_middleware_camel_context,
                       :name                  => 'Local',
                       :feed                  => the_feed_id,
                       :ems_ref               => '/t;hawkular'\
                                                 "/f;#{the_feed_id}/r;My%20Remote%20JMX~jboss.as:core-service%3Dpatching%2Clayer%3Dfuse/r;My%20Remote%20JMX~org.apache.camel:context%3Dcamel-1%2Cname%3D%22camel-1%22%2Ctype%3Dcontext",
                       :nativeid              => 'My Remote JMX~org.apache.camel:context=camel-1,name="camel-1",type=context',
                       :ext_management_system => ems_hawkular)
  end

  let(:expected_metrics) do
    {
      'CamelProcessorMetrics~ExchangesCompleted'  => 'mw_camel_exchanges_completed',
      'CamelProcessorMetrics~ExchangesFailed'     => 'mw_camel_exchanges_failed',
      'CamelProcessorMetrics~ExchangesTotal'      => 'mw_camel_exchanges_total',
      'CamelProcessorMetrics~LastProcessingTime'  => 'mw_camel_last_processing_time',
      'CamelProcessorMetrics~MaxProcessingTime'   => 'mw_camel_max_processing_time',
      'CamelProcessorMetrics~MeanProcessingTime'  => 'mw_camel_mean_processing_time',
      'CamelProcessorMetrics~MinProcessingTime'   => 'mw_camel_min_processing_time',
      'CamelProcessorMetrics~TotalProcessingTime' => 'mw_camel_total_processing_time',
    }.freeze
  end

  it "#collect_stats_metrics" do
    start_time = test_start_time
    end_time = test_end_time
    interval = 3600
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :match_requests_on              => [:method, :uri, :body],
                     :decode_compressed_response     => true) do #, :record => :new_episodes) do
      metrics_available = camel_context.metrics_available
      metrics_ids_map, raw_stats = camel_context.collect_stats_metrics(metrics_available, start_time, end_time, interval)
      expect(metrics_ids_map.keys.size).to be > 0
      expect(raw_stats.keys.size).to be > 0
    end
  end

  it "#collect_live_metrics for all metrics available" do
    start_time = test_start_time
    end_time = test_end_time
    interval = 3600
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :match_requests_on              => [:method, :uri, :body],
                     :decode_compressed_response     => true) do #, :record => :new_episodes) do
      metrics_available = camel_context.metrics_available
      metrics_data = camel_context.collect_live_metrics(metrics_available, start_time, end_time, interval)
      keys = metrics_data.keys
      expect(metrics_data[keys[0]].keys.size).to be > 3
    end
  end

  # it "#collect_live_metrics for three metrics" do
  #   start_time = test_start_time
  #   end_time = test_end_time
  #   interval = 3600
  #   VCR.use_cassette(described_class.name.underscore.to_s,
  #                    :allow_unused_http_interactions => true,
  #                    :match_requests_on              => [:method, :uri, :body],
  #                    :decode_compressed_response     => true) do # , :record => :new_episodes) do
  #     metrics_available = camel_context.metrics_available
  #     expect(metrics_available.size).to be > 3
  #     metrics_data = camel_context.collect_live_metrics(metrics_available[0, 3],
  #                                             start_time,
  #                                             end_time,
  #                                             interval)
  #     keys = metrics_data.keys
  #     # Assuming that for the test the first key has data for 3 metrics
  #     expect(metrics_data[keys[0]].keys.size).to eq(3)
  #   end
  # end

  it "#first_and_last_capture" do
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :decode_compressed_response     => true) do #, :record => :new_episodes) do
      capture = camel_context.first_and_last_capture
      expect(capture.any?).to be true
      expect(capture[0]).to be < capture[1]
    end
  end

  it "#supported_metrics" do
    supported_metrics = camel_context.supported_metrics
    expected_metrics.each { |k, v| expect(supported_metrics[k]).to eq(v) }

    _model, model_config = MiddlewareCamelContext.live_metrics_config.first
    supported_metrics = model_config['supported_metrics']
    expected_metrics.each { |k, v| expect(supported_metrics[k]).to eq(v) }
  end

  it "#metrics_available" do
    VCR.use_cassette(described_class.name.underscore.to_s,
                     :allow_unused_http_interactions => true,
                     :decode_compressed_response     => true) do #, :record => :new_episodes) do
      metrics_available = camel_context.metrics_available
      metrics_available.each { |metric| expect(expected_metrics.value?(metric[:name])).to be(true) }
    end
  end
end
