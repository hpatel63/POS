# API Contracts

## Authentication
- OAuth 2.1 Authorization Code with PKCE
- Token endpoint returns JWT access token with 15 minute expiration
- `X-Property-ID` header scopes multi-property operations

## REST Endpoints

### Reservations
- `POST /v1/reservations`
  - Request: `ReservationCreateRequest`
  - Response: `ReservationResponse`
- `PUT /v1/reservations/{id}`
  - Request: `ReservationUpdateRequest`
  - Response: `ReservationResponse`

### Payments
- `POST /v1/payments`
  - Request: `PaymentCreateRequest`
  - Response: `PaymentResponse`

### Housekeeping
- `GET /v1/housekeeping/rooms`
  - Query params: `status`, `propertyId`, `updatedAfter`
  - Response: `HousekeepingRoomsResponse`

### Search
- `GET /v1/search`
  - Query params: `q`, `entity`
  - Response: `SearchResponse`

### Reports
- `GET /v1/reports/{type}`
  - Query params: `format`, `start`, `end`
  - Response: `ReportDownloadResponse`

### AI Insights
- `GET /v1/insights`
  - Query params: `type`, `propertyId`
  - Response: `InsightResponse`

## GraphQL Schema Highlights

```
type Query {
  property(id: ID!): Property
  reservations(propertyId: ID!, range: DateRangeInput!): [Reservation!]!
  reports(input: ReportInput!): ReportPayload!
  search(input: SearchInput!): [SearchResult!]!
}

type Mutation {
  createReservation(input: ReservationInput!): Reservation!
  updateReservation(id: ID!, input: ReservationInput!): Reservation!
  recordPayment(input: PaymentInput!): Payment!
  logIncident(input: IncidentInput!): GuestIncident!
}
```

## Models

- `ReservationCreateRequest`
  - `propertyId: UUID`
  - `roomId: UUID`
  - `guestId: UUID`
  - `checkInDate: ISO8601`
  - `checkOutDate: ISO8601`
  - `ratePlanCode: String`
  - `nightlyRate: Decimal`
  - `taxes: [TaxLineItem]`
  - `payments: [PaymentIntent]`
- `PaymentIntent`
  - `method: String`
  - `amount: Decimal`
  - `token: String`
  - `status: String`

## Error Handling
- Standardized problem+json payload
- Error codes include `RESERVATION_CONFLICT`, `PAYMENT_DECLINED`, `AI_RATE_LIMIT`

## Rate Limiting
- 100 requests per minute per authenticated user
- Exceeding limit returns HTTP 429 with retry-after header

## Security
- TLS 1.2+
- All payment data tokenized; no raw PAN stored
- Audit logging per request with `X-Request-ID`
