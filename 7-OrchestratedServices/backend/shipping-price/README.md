# Shipping Service

## Testing

### Using [grpcurl](https://github.com/fullstorydev/grpcurl)

#### List Services

**Request**
```
grpcurl -plaintext localhost:9090 list
```

**Response**
```text
grpc.health.v1.Health
grpc.reflection.v1alpha.ServerReflection
io.wks.terraform.shippingpriceapi.ShippingPriceService
```

#### Success Scenario

**Request**
```
grpcurl --plaintext -d "{\"sourceCountry\": \"AE\", \"destinationCountry\": \"UK\", \"bookingDateTime\": \"\", \"currency\": \"AED\", \"weightKg\": \"3\", \"urgent\": true}" localhost:9090 io.wks.terraform.shippingpriceapi.ShippingPriceService/price
```

**Response**
```json
{
  "currency": "AED",
  "priceMinorUnits": "198000"
}
```

#### Error Scenario

**Request**
```
grpcurl --plaintext -d "{\"sourceCountry\": \"AE\", \"destinationCountry\": \"TR\", \"bookingDateTime\": \"\", \"currency\": \"AED\", \"weightKg\": \"3\", \"urgent\": true}" localhost:9090 io.wks.terraform.shippingpriceapi.ShippingPriceService/price```
```
**Response**

```text
ERROR:
Code: InvalidArgument
Message: Packages can not be delivered from 'AE' to 'TR'
```
