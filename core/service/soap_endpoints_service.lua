local soapEndpointsService = {}
local soapApiUtils = require("flux_gate/core/utils/soap_api_utils")

function soapEndpointsService.register()
    soapApiUtils.invokeSoapApi(ngx)
end

return soapEndpointsService