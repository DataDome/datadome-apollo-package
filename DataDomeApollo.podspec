Pod::Spec.new do |spec|
  spec.name     = "DataDomeApollo"
  spec.version  = "3.6.2"
  spec.summary  = "A DataDome plugin for Apollo integration."
  spec.homepage = "https://datadome.co"
  spec.license  = { :type => 'MIT', :file => 'LICENSE' }

  spec.author   = { "DataDome" => "dev@datadome.co" }

  spec.ios.deployment_target  = "11.0"
  spec.swift_version          = '5'

  spec.source       = { :git => "https://github.com/DataDome/datadome-apollo-package.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/DataDomeApollo"

  spec.dependency "Apollo", "~> 1.0"
  spec.dependency 'DataDomeSDK', "~> 3.6.2"
end