group "all" {
  targets = ["build", "sast-node", "sast-python", "test", "test-runtime", "runtime"]
}

target "common" {
  context = "."
  dockerfile = "Dockerfile"
  cache-to = ["type=inline"]
}

target "build" {
  inherits = ["common"]
  target = "build"
}

target "sast-node" {
  inherits = ["common"]
  target = "sast-node"
}

target "sast-python" {
  inherits = ["common"]
  target = "sast-python"
}

target "test" {
  inherits = ["common"]
  target = "test"
}

target "test-runtime" {
  inherits = ["common"]
  target = "test-runtime"
}

target "runtime" {
  inherits = ["common"]
  target = "runtime"
}
