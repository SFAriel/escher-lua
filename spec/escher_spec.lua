local date = require("date")
local socketUrl = require("socket.url")
local Escher = require("escher")
local TestSuite = require("spec.testsuite")

describe("Escher", function()
  describe(".signRequest", function()

    local function findHeader(request, headerName)
      for _, headerAndValuePair in pairs(request.headers) do
        if headerAndValuePair[1]:lower() == headerName:lower() then
          return headerAndValuePair[2]
        end
      end
    end

    local function trim(str)
      return string.match(str, "^%s*(.-)%s*$")
    end

    local function dateDiffInSeconds(date1, date2)
      return date.diff(date(trim(date1)), date(trim(date2))):spanseconds()
    end

    TestSuite.signing.forEach(function(filename, testData)

      local expected = testData.expected.authHeader

      if not expected then
        return
      end

      local config, request, headersToSign = testData.config, testData.request, testData.headersToSign
      local givenDateHeader = findHeader(request, config.dateHeaderName)

      if givenDateHeader then
        it("should only generate escher signature header when date given " .. filename, function()
          Escher(config):signRequest(request, headersToSign)

          local dateHeader = findHeader(request, config.dateHeaderName)
          local authHeader = findHeader(request, config.authHeaderName)

          assert.is_equal(givenDateHeader, dateHeader)
          assert.is_equal(expected, authHeader)
        end)
      else
        it("should generate escher signature and date headers " .. filename, function()
          Escher(config):signRequest(request, headersToSign)

          local dateHeader = findHeader(request, config.dateHeaderName)
          local authHeader = findHeader(request, config.authHeaderName)

          assert.is_equal(0, dateDiffInSeconds(config.date, dateHeader))
          assert.is_equal(expected, authHeader)
        end)
      end

    end)

  end)

  describe(".generatePreSignedUrl", function()

    TestSuite.generateSignedUrl.forEach(function(filename, testData)

      local expected = testData.expected.url

      if not expected then
        return
      end

      local config, request, headersToSign = testData.config, testData.request, testData.headersToSign

      it("should return the signed url " .. filename, function()
        local client = { config.accessKeyId, config.apiSecret }
        local signedUrl = Escher(config):generatePreSignedUrl(request.url, client, request.expires)

        assert.is_equal(expected, signedUrl)
      end)

    end)

  end)

  local function makeKeyRetriever(keyDb)
    return function(keyToFind)
      for _, keySecretPair in pairs(keyDb) do
        local key = keySecretPair[1]
        local secret = keySecretPair[2]

        if key == keyToFind then
          return secret
        end
      end
    end
  end

  describe(".authenticate", function()

    TestSuite.validation.forEach(function(filename, testData)

      local keyDb = makeKeyRetriever(testData.keyDb)
      local config, request = testData.config, testData.request
      local mandatorySignedHeaders = testData.mandatorySignedHeaders
      local expectedApiKey = testData.expected.apiKey
      local expectedError = testData.expected.error

      if expectedApiKey then
        it("should return api key when signature is valid " .. filename, function()
          local apiKey, err = Escher(config):authenticate(request, keyDb, mandatorySignedHeaders)

          assert.is_equal(expectedApiKey, apiKey)
          assert.is_nil(err)
        end)
      elseif expectedError then
        it("should return error when signature is insvalid " .. filename, function()
          local apiKey, err = Escher(config):authenticate(request, keyDb, mandatorySignedHeaders)

          assert.is_false(apiKey)
          assert.is_equal(expectedError, err)
        end)
      end

    end)

  end)

  describe(".generatePreSignedUrl with .authenticate", function()

    local MATCH_HOST = "^https?://.-[@?]([^:/%?]*)"
    local MATCH_PATH_AND_QUERY = "^https?://.-([/%?].*)"
    local function createRequestFromUrl(fullUrl)
      return {
        method = "GET",
        url = fullUrl:match(MATCH_PATH_AND_QUERY),
        body = "",
        headers = {
          { "Host", fullUrl:match(MATCH_HOST) }
        }
      }
    end

    TestSuite.generateAndAuthenticate.forEach(function(filename, testData)

      local keyDb = makeKeyRetriever(testData.keyDb)
      local config, request = testData.config, testData.request
      local mandatorySignedHeaders = testData.mandatorySignedHeaders
      local client = { config.accessKeyId, config.apiSecret }
      local expectedApiKey = testData.expected.apiKey
      local expectedError = testData.expected.error

      if expectedApiKey then
        it("should return api key when signature is valid " .. filename, function()
          local signedUrl = Escher(config):generatePreSignedUrl(request.url, client, request.expires)
          local signedRequest = createRequestFromUrl(signedUrl)
          local apiKey, err = Escher(config):authenticate(signedRequest, keyDb, mandatorySignedHeaders)

          assert.is_equal(expectedApiKey, apiKey)
          assert.is_nil(err)
        end)
      elseif expectedError then
        it("should return error when signature is insvalid " .. filename, function()
          local signedUrl = Escher(config):generatePreSignedUrl(request.url, client, request.expires)
          local signedRequest = createRequestFromUrl(signedUrl)
          local apiKey, err = Escher(config):authenticate(signedRequest, keyDb, mandatorySignedHeaders)

          assert.is_false(apiKey)
          assert.is_equal(expectedError, err)
        end)
      end

    end)

  end)
end)
