# Hwenti (حوانتي) — Flutter Frontend

A bilingual (Arabic RTL / French LTR) Tunisian local marketplace mobile & web application built in Flutter, connecting local merchants (**تاجر / Marchand**) and shoppers (**حريف / Client**) across all 24 Tunisian governorates and delegations.

## Features

- **Instant Runtime Bilingual & RTL/LTR Switching**: Switch seamlessly between Arabic (`ar`, RTL) with `Noto Sans Arabic` typography and French (`fr`, LTR) with `Inter` typography.
- **High-Contrast Dark Surface Palette**: Engineered for sunlight legibility (`#1A1A1A` background, `#2A2A2A` cards, `#FFD600` primary yellow branding, `#00BCD4` teal filter bar, `#4CAF50` action green).
- **Geolocation Auto-Detection**: Automatically resolves GPS coordinates via `/api/geolocation/nearest` to the nearest Tunisian governorate & delegation and tracks visitor statistics.
- **Full Marketplace Capabilities**:
  - Browse, search, and filter products by Governorate, Delegation, Trade Type, and Merchant
  - Product detail carousel, availability & expiry countdown, direct phone dialer (`tel:`), and native share sheet
  - Merchant storefront with star ratings, user reviews, follow/unfollow, and abuse reporting
  - Merchant shop setup, product publishing with 3-step presigned S3 upload, and visitor analytics dashboard

## Getting Started

```bash
cd flutter_space
flutter pub get
flutter run --dart-define=API_URL=http://localhost:3000
```
