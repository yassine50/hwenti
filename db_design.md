# Database Schema — حوانتي (Hwenti)

PostgreSQL with Prisma ORM. UUID primary keys, DateTime timestamps.

---

## Entities

### User
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| email | String | Unique, required |
| password | String | bcrypt hashed, required |
| name | String | Required |
| role | String | Required, enum: "merchant", "visitor" |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

Relations: has one Merchant (if role=merchant), has many Rating, Favorite, MerchantFollow, Report, Notification, PushToken, File

---

### Merchant
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, unique, required, ON DELETE CASCADE |
| shopName | String | Nullable (null until setup) |
| tradeType | String | Nullable, enum: "clothing", "food", "electronics", "furniture", "jewelry", "household", "toys", "other" |
| governorateId | UUID | FK to Governorate, nullable |
| delegationId | UUID | FK to Delegation, nullable |
| phone | String | Nullable |
| logoFileId | UUID | FK to File, nullable |
| setupComplete | Boolean | Default false |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

Relations: belongs to User, Governorate, Delegation, File (logo). Has many Product, Rating, MerchantFollow, Report.

Indexes: `userId` (unique), `governorateId`, `delegationId`, `tradeType`, `setupComplete`

---

### File
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| fileName | String | Required |
| cloud_storage_path | String | Unique, required |
| isPublic | Boolean | Default false |
| contentType | String | Required |
| fileSize | Integer | Nullable |
| createdAt | DateTime | Auto |

Relations: belongs to User

---

### Governorate
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| name | String | Unique, required (canonical name) |
| nameAr | String | Required (Arabic name) |
| nameFr | String | Required (French name) |
| latitude | Float | Required (center coordinate for geolocation matching) |
| longitude | Float | Required (center coordinate for geolocation matching) |
| createdAt | DateTime | Auto |

Relations: has many Delegation, Merchant, VisitorStat

Note: Pre-seeded with all 24 Tunisian governorates:
تونس, أريانة, بن عروس, منوبة, نابل, زغوان, بنزرت, باجة, جندوبة, الكاف, سليانة, سوسة, المنستير, المهدية, صفاقس, القيروان, القصرين, سيدي بوزيد, قابس, مدنين, تطاوين, قفصة, توزر, قبلي

---

### Delegation
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| governorateId | UUID | FK to Governorate, required, ON DELETE CASCADE |
| name | String | Required |
| nameAr | String | Required |
| nameFr | String | Required |
| latitude | Float | Nullable (center coordinate, optional for finer geolocation) |
| longitude | Float | Nullable |
| createdAt | DateTime | Auto |

Relations: belongs to Governorate. Has many Merchant, VisitorStat.

Indexes: `governorateId`, unique compound `[governorateId, name]`

---

### Product
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| merchantId | UUID | FK to Merchant, required, ON DELETE CASCADE |
| name | String | Required |
| price | Float | Required |
| phone | String | Required |
| description | String | Nullable |
| expiryDate | DateTime | Required |
| publishDate | DateTime | Required, default now |
| viewCount | Integer | Default 0 |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

Relations: belongs to Merchant. Has many ProductImage, Favorite.

Indexes: `merchantId`, `publishDate`, `expiryDate`

Note: `isAvailable` is computed at query time: `expiryDate > NOW() AND publishDate <= NOW()`

---

### ProductImage
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| productId | UUID | FK to Product, required, ON DELETE CASCADE |
| fileId | UUID | FK to File, required, ON DELETE CASCADE |
| isPrimary | Boolean | Default false |
| sortOrder | Integer | Default 0 |
| createdAt | DateTime | Auto |

Relations: belongs to Product, File

Indexes: `productId`, unique compound `[productId, sortOrder]`

---

### Rating
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| merchantId | UUID | FK to Merchant, required, ON DELETE CASCADE |
| score | Integer | Required, 1-5 |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

Relations: belongs to User, Merchant

Indexes: unique compound `[userId, merchantId]`

---

### Favorite
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| productId | UUID | FK to Product, required, ON DELETE CASCADE |
| createdAt | DateTime | Auto |

Relations: belongs to User, Product

Indexes: unique compound `[userId, productId]`

---

### MerchantFollow
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| merchantId | UUID | FK to Merchant, required, ON DELETE CASCADE |
| createdAt | DateTime | Auto |

Relations: belongs to User, Merchant

Indexes: unique compound `[userId, merchantId]`

---

### Notification
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| type | String | Required, enum: "new_product" |
| message | String | Required |
| productId | UUID | FK to Product, nullable, ON DELETE SET NULL |
| merchantId | UUID | FK to Merchant, required, ON DELETE CASCADE |
| isRead | Boolean | Default false |
| createdAt | DateTime | Auto |

Relations: belongs to User, Product (optional), Merchant

Indexes: `userId`, `isRead`, `createdAt`

---

### Report
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| merchantId | UUID | FK to Merchant, required, ON DELETE CASCADE |
| reason | String | Required, enum: "counterfeit", "fraud", "inappropriate", "other" |
| details | String | Nullable |
| createdAt | DateTime | Auto |

Relations: belongs to User, Merchant

Indexes: `merchantId`, `userId`

---

### VisitorStat
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| governorateId | UUID | FK to Governorate, nullable |
| delegationId | UUID | FK to Delegation, nullable |
| latitude | Float | Nullable |
| longitude | Float | Nullable |
| createdAt | DateTime | Auto |

Relations: belongs to Governorate (optional), Delegation (optional)

Indexes: `governorateId`, `delegationId`, `createdAt`

Note: Each record represents one app-open event. No user FK — tracks anonymous visits.

---

### PushToken
| Field | Type | Constraints |
|-------|------|-------------|
| id | UUID | PK, auto-generated |
| userId | UUID | FK to User, required, ON DELETE CASCADE |
| token | String | Unique, required |
| deviceType | String | Required, enum: "ios", "android" |
| createdAt | DateTime | Auto |

Relations: belongs to User

---

## Seed Data

The database must be seeded with:
1. All 24 Tunisian governorates with Arabic names, French names, and approximate center GPS coordinates
2. All delegations for each governorate (approximately 264 total delegations) with Arabic and French names

This seed data is critical for the filtering system and geolocation features to work on first launch.
