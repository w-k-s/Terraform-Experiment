## Sample request

```text
curl -X POST \
  http://localhost:8081/api/v1/order \
  -H 'Content-Type: application/json' \
  -d '{
  "customerId": 123456789,
  "currency": "AED",
  "lineItems": [
    {
      "productId": "550e8400-e29b-41d4-a716-446655440000",
      "unitWeight": 0.5,
      "units": 2
    },
    {
      "productId": "8b5f8847-3c3b-4d6e-85df-23746c8047f5",
      "unitWeight": 0.75,
      "units": 3
    }
  ],
  "delivery": {
    "address": {
      "countryCode": "TR"
    },
    "urgent": true
  }
}'

```