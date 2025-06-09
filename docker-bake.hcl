group "all" {
  targets = ["build", "sast-node", "sast-python", "test", "test-runtime", "runtime"]
}

target "common" {
  context = "."
  dockerfile = "Dockerfile"
}

target "build" {
  inherits = ["common"]
  target = "build"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-build:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-build:cache,mode=max"]
}

target "sast-node" {
  inherits = ["common"]
  target = "sast-node"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-sast-node:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-sast-node:cache,mode=max"]
}

target "sast-python" {
  inherits = ["common"]
  target = "sast-python"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-sast-python:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-sast-python:cache,mode=max"]
}

target "test" {
  inherits = ["common"]
  target = "test"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-test:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-test:cache,mode=max"]
}

target "test-runtime" {
  inherits = ["common"]
  target = "test-runtime"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-test-runtime:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-test-runtime:cache,mode=max"]
}

target "runtime" {
  inherits = ["common"]
  target = "runtime"
  cache-from = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-runtime:cache"]
  cache-to = ["type=registry,ref=${CI_REGISTRY_IMAGE}/myapp-runtime:cache,mode=max"]
}
