local json = require("rapidjson")

local testFiles = {
  signing = {
    "spec/aws4_testsuite/signrequest-get-vanilla.json",
    "spec/aws4_testsuite/signrequest-post-vanilla.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-query.json",
    "spec/aws4_testsuite/signrequest-post-vanilla-query.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-empty-query-key.json",
    "spec/aws4_testsuite/signrequest-post-vanilla-empty-query-value.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-query-order-key.json",
    "spec/aws4_testsuite/signrequest-post-x-www-form-urlencoded.json",
    "spec/aws4_testsuite/signrequest-post-x-www-form-urlencoded-parameters.json",
    "spec/aws4_testsuite/signrequest-get-header-value-trim.json",
    "spec/aws4_testsuite/signrequest-post-header-key-case.json",
    "spec/aws4_testsuite/signrequest-post-header-key-sort.json",
    "spec/aws4_testsuite/signrequest-post-header-value-case.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-query-order-value.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-query-order-key-case.json",
    "spec/aws4_testsuite/signrequest-get-unreserved.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-query-unreserved.json",
    "spec/aws4_testsuite/signrequest-get-vanilla-ut8-query.json",
    "spec/aws4_testsuite/signrequest-get-utf8.json",
    "spec/aws4_testsuite/signrequest-get-space.json",
    "spec/aws4_testsuite/signrequest-post-vanilla-query-space.json",
    "spec/aws4_testsuite/signrequest-post-vanilla-query-nonunreserved.json",
    "spec/aws4_testsuite/signrequest-get-slash.json",
    "spec/aws4_testsuite/signrequest-get-slashes.json",
    "spec/aws4_testsuite/signrequest-get-slash-dot-slash.json",
    "spec/aws4_testsuite/signrequest-get-slash-pointless-dot.json",
    "spec/aws4_testsuite/signrequest-get-relative.json",
    "spec/aws4_testsuite/signrequest-get-relative-relative.json",
    "spec/emarsys_testsuite/signrequest-get-header-key-duplicate.json",
    "spec/emarsys_testsuite/signrequest-get-header-value-order.json",
    "spec/emarsys_testsuite/signrequest-post-header-key-order.json",
    "spec/emarsys_testsuite/signrequest-post-header-value-spaces.json",
    "spec/emarsys_testsuite/signrequest-post-header-value-spaces-within-quotes.json",
    "spec/emarsys_testsuite/signrequest-post-payload-utf8.json",
    "spec/emarsys_testsuite/signrequest-date-header-should-be-signed-headers.json",
    "spec/emarsys_testsuite/signrequest-only-sign-specified-headers.json",
    "spec/emarsys_testsuite/signrequest-support-custom-config.json",
    "spec/emarsys_testsuite/signrequest-support-custom-config-with-customer-id.json",
    "spec/emarsys_testsuite/signrequest-empty-query-param.json"
  },
  validation = {
    "spec/emarsys_testsuite/authenticate-error-date-header-auth-header-date-not-equal.json",
    "spec/emarsys_testsuite/authenticate-error-date-header-not-signed.json",
    "spec/emarsys_testsuite/authenticate-error-host-header-not-signed.json",
    "spec/emarsys_testsuite/authenticate-error-invalid-auth-header.json",
    "spec/emarsys_testsuite/authenticate-error-invalid-credential-scope.json",
    "spec/emarsys_testsuite/authenticate-error-invalid-escher-key.json",
    "spec/emarsys_testsuite/authenticate-error-invalid-hash-algorithm.json",
    "spec/emarsys_testsuite/authenticate-error-missing-auth-header.json",
    "spec/emarsys_testsuite/authenticate-error-missing-date-header.json",
    "spec/emarsys_testsuite/authenticate-error-missing-host-header.json",
    "spec/emarsys_testsuite/authenticate-error-presigned-url-expired.json",
    "spec/emarsys_testsuite/authenticate-error-request-date-invalid.json",
    "spec/emarsys_testsuite/authenticate-error-wrong-signature.json",
    "spec/emarsys_testsuite/authenticate-valid-authentication-datein-expiretime.json",
    "spec/emarsys_testsuite/authenticate-valid-get-vanilla-empty-query-with-custom-headernames.json",
    "spec/emarsys_testsuite/authenticate-valid-get-vanilla-empty-query.json",
    "spec/emarsys_testsuite/authenticate-valid-ignore-headers-order.json",
    "spec/emarsys_testsuite/authenticate-valid-presigned-url-with-query.json",
    "spec/emarsys_testsuite/authenticate-valid-presigned-double-url-encoded.json",
    "spec/emarsys_testsuite/authenticate-valid-credential-with-spaces.json",
    "spec/emarsys_testsuite/authenticate-error-mandatoryheaders-not-array-of-strings.json",
    "spec/emarsys_testsuite/authenticate-error-mandatoryheaders-not-array.json",
    "spec/emarsys_testsuite/authenticate-error-notsigned-header.json",
    "spec/emarsys_testsuite/authenticate-error-get-uppercase-signed-header.json"
  },
  generateSignedUrl = {
    "spec/emarsys_testsuite/presignurl-valid-with-path-query.json",
    "spec/emarsys_testsuite/presignurl-valid-with-port.json",
    "spec/emarsys_testsuite/presignurl-valid-with-hash.json",
    "spec/emarsys_testsuite/presignurl-valid-with-URL-encoded-array-parameters.json",
    "spec/emarsys_testsuite/presignurl-valid-with-double-url-encoded.json"
  },
  generateAndAuthenticate = {
    "spec/emarsys_testsuite/authenticate-valid-with-generating-presigned-url-with-query.json",
  }
}

local function decodeJson(filename)
  local file = assert(io.open(filename, "r"))
  local content = file:read("*all")

  file:close()

  return json.decode(content)
end

local function createFileRunner(files)
  return function(callback)
    for _, filename in pairs(files) do
      callback(filename, decodeJson(filename))
    end
  end
end

local TestSuite = {}

for testType, files in pairs(testFiles) do
  TestSuite[testType] = {
    forEach = createFileRunner(files)
  }
end

return TestSuite
