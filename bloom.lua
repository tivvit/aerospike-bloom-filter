function add(rec, bin, value)
    local default_count = 10000
    local default_probability = 0.01
    local default_ttl = 14400 -- 4 hours

    local bloom_filter = require "bloom_filter"
    local function storeBloom(bf, rec, bin)
        local data = bytes(bf:items())
        bytes.set_string(data, 1, bf:tostring())
        rec[bin] = data
        rec[bin .. "_count"] = bf:count()
        rec[bin .. "_probability"] = bf:probability()
        rec[bin .. "_items"] = bf:items()
        rec[bin .. "_bytes"] = bf:bytes()
        return rec
    end

    if default_ttl > 0 then
        record.set_ttl(rec, default_ttl)
    end

    local found = false

    if aerospike:exists(rec) then
        if rec[bin] ~= nil then
            local count = rec[bin .. "_count"]
            local probability = rec[bin .. "_probability"]
            local items = rec[bin .. "_items"]
            local bytes_cnt = rec[bin .. "_bytes"]

            local bf = bloom_filter.new(items, probability)
            bloomStr = bytes.get_string(rec[bin], 1, bytes_cnt)
            --bloomStr = bytes.get_bytes(rec[bin], 1, bytes_cnt)
            --info(tostring(bloomStr))
            bf:fromstring(count, bloomStr)
            found = bf:query(value)
            if not found then
                bf:add(value)
                local data = bytes(bf:items())
                bytes.set_string(data, 1, bf:tostring())
                rec[bin] = data
                rec[bin .. "_count"] = bf:count()
                aerospike:update(rec)
            end
        else
            local bf = bloom_filter.new(default_count, default_probability)
            bf:add(value)
            rec = storeBloom(bf, rec, bin)
            aerospike:update(rec)
        end
    else
        local bf = bloom_filter.new(default_count, default_probability)
        bf:add(value)
        rec = storeBloom(bf, rec, bin)
        aerospike:create(rec)
    end
    return found
end
