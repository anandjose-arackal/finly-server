# Geocoder.configure(ip_lookup: :ipstack, api_key: '7430b2a577177801e07b9cd666c16fe9')

Geocoder.configure( ip_lookup: :geoip2, geoip2: { file: File.join("#{Rails.root}/lib/geo_ip", 'GeoLite2-City.mmdb') } )