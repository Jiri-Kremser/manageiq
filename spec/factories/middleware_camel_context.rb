FactoryGirl.define do
  factory :middleware_camel_context do
    sequence(:name) { |n| "middleware_camel_context_#{seq_padded_for_sorting(n)}" }
  end

  factory :hawkular_middleware_camel_context,
          :aliases => ['app/models/manageiq/providers/hawkular/middleware_manager/middleware_camel_context'],
          :class   => 'ManageIQ::Providers::Hawkular::MiddlewareManager::MiddlewareCamelContext',
          :parent  => :middleware_camel_context do
  end
end
