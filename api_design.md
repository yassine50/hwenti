# API Specification — حوانتي (Hwenti)

Base URL: `/api`
All authenticated endpoints require `Authorization: Bearer <token>` header.

---

## Auth

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/signup | {email: string (required), password: string (required), name: string (required), role: string (required, "merchant" or "visitor")} | {token: string, user: {id: UUID, email: string, name: string, role: string, merchantSetupComplete: boolean}} | No |
| POST | /api/auth/login | {email: string (required), password: string (required)} | {token: string, user: {id: UUID, email: string, name: string, role: string, merchantSetupComplete: boolean}} | No |
| GET | /api/auth/me | — | {user: {id: UUID, email: string, name: string, role: string, merchantSetupComplete: boolean}} | Bearer |

Note: `merchantSetupComplete` is `true` for visitors (always), and for merchants only after they complete merchant profile setup. Signup with role="merchant" creates a Merchant record with null fields and `setupComplete=false`.

---

## File Uploads

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/upload/presigned | {fileName: string (required), contentType: string (required), isPublic: boolean (optional, default true)} | {uploadUrl: string, cloud_storage_path: string} | Yes |
| POST | /api/upload/complete | {cloud_storage_path: string (required), fileName: string (required), contentType: string (required), fileSize: integer (optional)} | {id: UUID, cloud_storage_path: string, fileName: string} | Yes |
| GET | /api/files/:id/url?mode=view\|download | — | {url: string} | Yes |
| DELETE | /api/files/:id | — | {success: boolean} | Yes |

---

## Merchants

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/merchants/setup | {shopName: string (required), tradeType: string (required), governorateId: UUID (required), delegationId: UUID (required), phone: string (required), logoFileId: UUID (optional)} | {id: UUID, shopName: string, tradeType: string, governorateId: UUID, governorateName: string, delegationId: UUID, delegationName: string, phone: string, logoFileId: UUID \| null, logoUrl: string \| null, averageRating: number, ratingCount: integer, setupComplete: boolean} | Yes (merchant) |
| PATCH | /api/merchants/me | {shopName: string (optional), tradeType: string (optional), governorateId: UUID (optional), delegationId: UUID (optional), phone: string (optional), logoFileId: UUID (optional)} | Same as setup response | Yes (merchant) |
| GET | /api/merchants/:id | — | {id: UUID, userId: UUID, shopName: string, tradeType: string, governorateId: UUID, governorateName: string, delegationId: UUID, delegationName: string, phone: string, logoFileId: UUID \| null, logoUrl: string \| null, averageRating: number, ratingCount: integer, createdAt: ISO8601} | No |
| GET | /api/merchants | query: ?governorateId=UUID&delegationId=UUID&tradeType=string&search=string&page=integer&limit=integer | {items: Merchant[], total: integer, page: integer, totalPages: integer} | No |

Note: `POST /api/merchants/setup` also sets `setupComplete=true` on the Merchant record. The `merchantSetupComplete` field in auth responses derives from this.

---

## Products

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/products | {name: string (required), price: number (required), phone: string (required), description: string (optional), expiryDate: ISO8601 (required), publishDate: ISO8601 (optional, default now), imageFileIds: UUID[] (required, 1-6)} | {id: UUID, name: string, price: number, phone: string, description: string \| null, expiryDate: ISO8601, publishDate: ISO8601, viewCount: integer, isAvailable: boolean, merchant: {id: UUID, shopName: string, averageRating: number, logoFileId: UUID \| null, logoUrl: string \| null}, images: {id: UUID, fileId: UUID, url: string, isPrimary: boolean, sortOrder: integer}[], isFavorited: boolean, createdAt: ISO8601} | Yes (merchant) |
| PATCH | /api/products/:id | {name: string (optional), price: number (optional), phone: string (optional), description: string (optional), expiryDate: ISO8601 (optional), publishDate: ISO8601 (optional), imageFileIds: UUID[] (optional)} | Same as POST response | Yes (merchant, owner) |
| DELETE | /api/products/:id | — | {success: boolean} | Yes (merchant, owner) |
| GET | /api/products/:id | — | Same as POST response + viewCount incremented | No (isFavorited=false if unauthenticated) |
| GET | /api/products | query: ?governorateId=UUID&delegationId=UUID&tradeType=string&merchantId=UUID&search=string&available=boolean&page=integer&limit=integer | {items: Product[], total: integer, page: integer, totalPages: integer} | No (isFavorited populated if authenticated) |
| GET | /api/products/mine | query: ?page=integer&limit=integer | {items: Product[], total: integer, page: integer, totalPages: integer} | Yes (merchant) |

Product list item shape (in items array):
```
{
  id: UUID,
  name: string,
  price: number,
  phone: string,
  description: string | null,
  expiryDate: ISO8601,
  publishDate: ISO8601,
  viewCount: integer,
  isAvailable: boolean,
  merchant: {id: UUID, shopName: string, averageRating: number, logoFileId: UUID | null, logoUrl: string | null},
  primaryImageUrl: string,
  imageCount: integer,
  isFavorited: boolean,
  createdAt: ISO8601
}
```

Note: `isAvailable` is computed: `expiryDate > now AND publishDate <= now`.

---

## Product View Count

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/products/:id/view | — | {viewCount: integer} | No |

---

## Ratings

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/merchants/:id/ratings | {score: integer (required, 1-5)} | {id: UUID, merchantId: UUID, score: integer, createdAt: ISO8601} | Yes |
| GET | /api/merchants/:id/ratings | query: ?page=integer&limit=integer | {items: {id: UUID, score: integer, userName: string, createdAt: ISO8601}[], average: number, total: integer} | No |

Note: One rating per user per merchant. POST upserts (updates if exists).

---

## Favorites

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/favorites/:productId | — | {success: boolean} | Yes |
| DELETE | /api/favorites/:productId | — | {success: boolean} | Yes |
| GET | /api/favorites | query: ?page=integer&limit=integer | {items: Product[], total: integer, page: integer, totalPages: integer} | Yes |

Note: Product items in favorites response have same shape as product list items.

---

## Merchant Follows & Notifications

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/follows/:merchantId | — | {success: boolean} | Yes |
| DELETE | /api/follows/:merchantId | — | {success: boolean} | Yes |
| GET | /api/follows | query: ?page=integer&limit=integer | {items: {id: UUID, merchant: {id: UUID, shopName: string, tradeType: string, governorateName: string, logoFileId: UUID \| null, logoUrl: string \| null}, createdAt: ISO8601}[], total: integer, page: integer, totalPages: integer} | Yes |
| GET | /api/notifications | query: ?page=integer&limit=integer | {items: {id: UUID, type: string, message: string, productId: UUID \| null, merchantId: UUID, merchantName: string, merchantLogoUrl: string \| null, isRead: boolean, createdAt: ISO8601}[], total: integer, page: integer, totalPages: integer} | Yes |
| PATCH | /api/notifications/:id/read | — | {success: boolean} | Yes |

Note: When a merchant publishes a product, the backend creates Notification records for all followers of that merchant.

---

## Reports

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/reports | {merchantId: UUID (required), reason: string (required, one of: "counterfeit", "fraud", "inappropriate", "other"), details: string (optional)} | {id: UUID, merchantId: UUID, reason: string, createdAt: ISO8601} | Yes |

---

## Governorates & Delegations

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| GET | /api/governorates | — | {items: {id: UUID, name: string, nameAr: string, nameFr: string}[]} | No |
| GET | /api/governorates/:id/delegations | — | {items: {id: UUID, name: string, nameAr: string, nameFr: string, governorateId: UUID}[]} | No |

---

## Geolocation

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/geolocation/nearest | {latitude: number (required), longitude: number (required)} | {governorate: {id: UUID, name: string, nameAr: string, nameFr: string}, delegation: {id: UUID, name: string, nameAr: string, nameFr: string} \| null} | No |

Note: Backend matches coordinates to nearest governorate using pre-seeded center coordinates for each governorate. Returns closest match.

---

## Visitor Statistics

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/visitor-stats/track | {governorateId: UUID (optional), delegationId: UUID (optional), latitude: number (optional), longitude: number (optional)} | {success: boolean} | No |
| GET | /api/visitor-stats/summary | — | {totalVisitors: integer, byGovernorate: {governorateId: UUID, governorateName: string, count: integer}[], byDelegation: {delegationId: UUID, delegationName: string, governorateId: UUID, count: integer}[]} | Yes |

Note: `track` is called on app open with detected location. Creates a VisitorStat record. `summary` aggregates all records.

---

## Push Notifications

| Method | Path | Request Body | Response Body | Auth |
|--------|------|-------------|---------------|------|
| POST | /api/push-tokens | {token: string (required), deviceType: string (required: "ios" or "android")} | {success: boolean} | Yes |
| DELETE | /api/push-tokens/:token | — | {success: boolean} | Yes |

Note: When a merchant publishes a product, backend sends push notifications to all followers via FCM (Android) / APNs (iOS) using stored device tokens.
