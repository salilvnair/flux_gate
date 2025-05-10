local gatedResponse = {}

function gatedResponse.generate(gate, gatedUrl, metadata)
    return {
        gate = gate,
        gatedUrl = gatedUrl,
        metadata = metadata
        
    }
end
return gatedResponse