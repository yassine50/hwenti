# UX Specification — حوانتي (Hwenti)

## App Identity
- **Name**: حوانتي (Hwenti)
- **Tagline**: Tunisian Commercial Marketplace
- **Orientation**: Portrait
- **Bilingual**: Arabic (RTL) / French (LTR), switchable at runtime

---

## File Structure (expo-router)

```
app/
  _layout.tsx              # Root layout: LocaleProvider, AuthProvider, font loading, splash guard
  auth/
    _layout.tsx            # Auth guard: if isAuthenticated → <Redirect href="/tabs" />
    login.tsx              # Login screen
    signup.tsx             # Signup screen (role selection: merchant/visitor)
  tabs/
    _layout.tsx            # Auth guard: if !isAuthenticated → <Redirect href="/auth/login" />; <Tabs> with 5 tabs
    index.tsx              # Home (product feed)
    filter.tsx             # Filter screen
    favorites.tsx          # Favorites list
    notifications.tsx      # Notifications / follows
    profile.tsx            # Profile & settings
  product/
    [productId]/
      index.tsx            # Product detail
      edit.tsx             # Edit product (merchant owner only)
  merchant/
    [merchantId]/
      index.tsx            # Merchant public profile + products
      report.tsx           # Report merchant
  add-product.tsx          # Add new product (merchant only)
  merchant-setup.tsx       # Post-signup merchant profile setup
  dashboard.tsx            # Visitor statistics dashboard
```

---

## Screens

### 1. Login Screen (`auth/login.tsx`)
- **Purpose**: Authenticate existing users
- **Layout**:
  - Yellow header bar with centered "حوانتي" logo text (Display 32px, bold)
  - Language toggle button (top-left): "ع / FR"
  - Card with glass effect on dark gray (#1A1A1A) background
  - Email input (floating label)
  - Password input (floating label, show/hide toggle)
  - "تسجيل الدخول / Se connecter" gradient button [#FFD600, #FFC107]
  - "إنشاء حساب / Créer un compte" text link → push to signup
- **Actions**: Submit calls `login()` from AuthProvider; on success AuthProvider state updates, layout switches to tabs

### 2. Signup Screen (`auth/signup.tsx`)
- **Purpose**: Register new merchant or visitor
- **Layout**:
  - Same yellow header with logo and language toggle
  - Role selector: two large tappable cards side by side
    - "تاجر / Marchand" card with shop icon, green (#4CAF50) border when selected
    - "حريف / Client" card with user icon, tiffany (#00BCD4) border when selected
  - Name input
  - Email input
  - Password input (min 8 chars)
  - Confirm password input
  - "إنشاء حساب / Créer un compte" gradient button [#FFD600, #FFC107]
  - "لديك حساب؟ / Déjà inscrit?" text link → pop back to login
- **Actions**: Submit calls `signup()` with `{name, email, password, role}`. AuthProvider state updates; layout switches to tabs. If role is merchant, the tabs layout checks `user.merchantSetupComplete` flag — if false, redirects to `merchant-setup.tsx`.

### 3. Merchant Setup Screen (`merchant-setup.tsx`)
- **Purpose**: Collect merchant profile details post-signup
- **Layout**:
  - Yellow header "إعداد المتجر / Configuration du magasin"
  - Dark background with glass card
  - Logo upload circle (tap to pick image, uploads via presigned URL flow)
  - Shop name input (required)
  - Trade type dropdown: ملابس, مواد غذائية, إلكترونيات, أثاث, مجوهرات, أدوات منزلية, ألعاب, أخرى
  - Governorate dropdown (24 options, fetched from API)
  - Delegation dropdown (filtered by selected governorate)
  - Phone number input (numeric, +216 prefix)
  - "حفظ / Enregistrer" green (#4CAF50) gradient button
- **Actions**: Submit POST to create/update merchant profile. On success, navigate back to tabs (the redirect condition clears).

### 4. Home Screen (`tabs/index.tsx`) — Tab: 🏠 الرئيسية / Accueil
- **Purpose**: Main product feed, auto-filtered by nearest location
- **Layout**:
  - **Yellow header bar** (#FFD600):
    - Left: Language toggle button "ع/FR"
    - Center: "حوانتي" logo text (bold, dark text)
    - Right: Search icon button, then two small pill buttons: "متجر" (green bg) for merchant actions, "حريف" (tiffany bg) for visitor view
  - **Tiffany blue filter bar** (#00BCD4): horizontal scrollable chips showing current filters: الولاية | المعتمدية | نوع التجارة | التاجر — tapping any chip opens the Filter screen with that section focused
  - **Location banner**: small banner below filter bar showing detected governorate/delegation with a "تغيير / Changer" link
  - **Product grid**: 1-column list using @shopify/flash-list
    - Each **Product Card**:
      - Large product image (aspect ratio 4:3, rounded top corners 12px)
      - Yellow banner (#FFD600) overlay at bottom of image with product name (bold, dark text, 18px)
      - Below image: row of small thumbnail circles (up to 5 additional images)
      - Price in bold green (#4CAF50), 20px
      - Phone number (tappable, opens dialer)
      - Publish date (caption, 12px, muted)
      - View count with eye icon
      - Availability badge: green "متوفر/Disponible" or red "منتهي/Expiré"
      - Merchant name (tappable → push merchant profile)
      - Star rating (1-5 filled stars, yellow)
      - Heart icon (toggle favorite)
  - **FAB** (merchant only): "+" button, green (#4CAF50), bottom-right → push to add-product
- **On mount**: Request location permission → get GPS coords → POST to `/api/visitor-stats/track` → call `/api/geolocation/nearest` to get governorate/delegation → load products filtered by that location
- **Pull to refresh**: Reload product feed

### 5. Filter Screen (`tabs/filter.tsx`) — Tab: 🔍 تصفية / Filtrer
- **Purpose**: Chain filter: Governorate → Delegation → Trade Type → Merchant
- **Layout**:
  - Dark background
  - Four collapsible sections, each with a search input at top:
    1. **الولاية / Gouvernorat**: List of 24 governorates, single select, checkmark indicator
    2. **المعتمدية / Délégation**: Appears after governorate selected, lists delegations for that governorate
    3. **نوع التجارة / Type de commerce**: 8 trade type chips in a wrap layout, multi-select
    4. **التاجر / Marchand**: Search-as-you-type merchant list filtered by above selections
  - "تطبيق / Appliquer" green button at bottom → applies filters and switches to Home tab with filtered results
  - "مسح / Effacer" text button to clear all filters
- **State**: Filter state stored in a FilterContext shared with Home screen

### 6. Favorites Screen (`tabs/favorites.tsx`) — Tab: ❤️ المفضلة / Favoris
- **Purpose**: View saved favorite products
- **Layout**:
  - Yellow header "المفضلة / Favoris"
  - Same product card layout as Home but only favorited products
  - Swipe left to remove from favorites (with haptic)
  - Empty state: heart icon + "لا توجد مفضلات / Aucun favori" message
- **Data**: GET `/api/favorites`

### 7. Notifications Screen (`tabs/notifications.tsx`) — Tab: 🔔 إشعارات / Notifications
- **Purpose**: View notifications from followed merchants and manage follows
- **Layout**:
  - Segmented control at top: "إشعارات / Notifications" | "متابعات / Suivis"
  - **Notifications tab**: List of notification cards (merchant posted new product), each showing merchant logo, message, timestamp. Tap → push to product detail.
  - **Follows tab**: List of followed merchants with unfollow button. Each row: merchant logo, shop name, trade type, governorate. Tap row → push merchant profile.
  - Empty states for both tabs
- **Data**: GET `/api/notifications`, GET `/api/follows`

### 8. Profile Screen (`tabs/profile.tsx`) — Tab: 👤 الملف / Profil
- **Purpose**: View/edit profile, access dashboard, logout
- **Layout**:
  - User avatar/logo circle at top
  - Name, email, role badge ("تاجر" green or "حريف" tiffany)
  - **For merchants**:
    - Shop info card: shop name, trade type, governorate, delegation, phone
    - "تعديل المتجر / Modifier" button → push to merchant-setup (reuse for editing)
    - "منتجاتي / Mes produits" button → shows own products list with edit/delete actions
    - "لوحة الإحصائيات / Tableau de bord" button → push to dashboard
  - **For visitors**:
    - "لوحة الإحصائيات / Tableau de bord" button → push to dashboard
  - Language preference display
  - "تسجيل الخروج / Déconnexion" red outlined button at bottom
- **Actions**: Logout calls `logout()` from AuthProvider; state updates, layout switches to auth

### 9. Product Detail Screen (`product/[productId]/index.tsx`)
- **Purpose**: Full product view with all images, merchant info, actions
- **Layout**:
  - Back arrow in header
  - **Image carousel**: Full-width main image with swipe, dot indicators
  - Thumbnail row below (tappable to switch main image)
  - Yellow banner with product name
  - Price (large, green)
  - Description text (if provided)
  - Availability badge with expiry date
  - Publish date, view count
  - Divider
  - **Merchant section**: Logo, shop name (tappable → merchant profile), star rating, governorate/delegation
  - **Action buttons row**:
    - "اتصل / Appeler" green button (opens phone dialer via `Linking.openURL('tel:...')`)
    - Heart toggle (favorite)
    - Share button (OS share sheet)
    - Report flag icon (→ push to report)
  - **Rating section** (authenticated users): tap 1-5 stars to rate the merchant
- **On mount**: POST view count increment

### 10. Edit Product Screen (`product/[productId]/edit.tsx`)
- **Purpose**: Edit own product (merchant only)
- **Layout**: Same form as Add Product, pre-filled with existing data
- **Actions**: PATCH product, manage images (add/remove)

### 11. Add Product Screen (`add-product.tsx`)
- **Purpose**: Create new product listing (merchant only)
- **Layout**:
  - Yellow header "إضافة منتج / Ajouter un produit"
  - Image picker area: tap to add images (up to 6), drag to reorder, X to remove. First image = primary.
  - Product name input (required)
  - Price input (numeric, TND currency)
  - Phone number input (pre-filled from merchant profile)
  - Description textarea (optional)
  - Availability duration picker: date picker for expiry date
  - Auto publish date picker (optional, defaults to now)
  - "نشر / Publier" green gradient button
- **Upload flow**: Each image → POST `/api/upload/presigned` → upload to S3 → POST `/api/upload/complete` → collect fileIds → submit product with image fileIds

### 12. Merchant Profile Screen (`merchant/[merchantId]/index.tsx`)
- **Purpose**: Public merchant page
- **Layout**:
  - Merchant logo (large circle)
  - Shop name, trade type badge, governorate/delegation
  - Star rating (average, with count)
  - Phone number (tappable)
  - "متابعة / Suivre" toggle button (tiffany when following)
  - Report flag icon → push to report
  - Divider
  - "منتجات التاجر / Produits du marchand" section: product list (same card style)
- **Data**: GET `/api/merchants/:id`, GET `/api/products?merchantId=:id`

### 13. Report Screen (`merchant/[merchantId]/report.tsx`)
- **Purpose**: Report fraudulent merchant
- **Layout**:
  - Header "إبلاغ / Signaler"
  - Reason selection (radio buttons):
    - منتجات مزيفة / Produits contrefaits
    - احتيال / Fraude
    - محتوى غير لائق / Contenu inapproprié
    - أخرى / Autre
  - Additional details textarea (optional)
  - "إرسال / Envoyer" red button
  - Success confirmation with auto-pop back

### 14. Dashboard Screen (`dashboard.tsx`)
- **Purpose**: Visitor statistics visualization
- **Layout**:
  - Yellow header "الإحصائيات / Statistiques"
  - **Total visitors** card: large number with icon
  - **Visitors by governorate**: horizontal bar chart (sorted descending), each bar labeled with governorate name and count
  - **Visitors by delegation**: appears after tapping a governorate bar, shows delegation breakdown
  - Charts rendered with `react-native-chart-kit` or simple View-based bars
  - Pull to refresh
- **Data**: GET `/api/visitor-stats/summary`

---

## Navigation

### Unauthenticated Flow
- `auth/_layout.tsx`: if `isLoading` → splash; if `isAuthenticated` → `<Redirect href="/tabs" />`
- Stack: Login → Signup (push/pop between them)

### Authenticated Flow
- `tabs/_layout.tsx`: if `isLoading` → splash; if `!isAuthenticated` → `<Redirect href="/auth/login" />`
- If merchant and `!merchantSetupComplete` → `<Redirect href="/merchant-setup" />`
- 5 bottom tabs with icons and bilingual labels:
  1. 🏠 الرئيسية / Accueil
  2. 🔍 تصفية / Filtrer
  3. ❤️ المفضلة / Favoris
  4. 🔔 إشعارات / Notifications
  5. 👤 الملف / Profil
- Tab bar: dark background (#1A1A1A), active tab icon in yellow (#FFD600), inactive in gray

### Stack Navigation (outside tabs)
- Product detail, edit product, add product, merchant profile, report, dashboard, merchant-setup are all stack screens pushed from within tabs

---

## Design Direction

### Color Palette
- **Primary**: Yellow #FFD600 (headers, banners, active states)
- **Secondary**: Tiffany Blue #00BCD4 (filter bar, visitor role, follow buttons)
- **Action**: Green #4CAF50 (CTA buttons, prices, merchant role)
- **Background**: Dark gray #1A1A1A (content areas), #0F0F0F (screen bg)
- **Surface**: #2A2A2A (cards), #333333 (elevated cards)
- **Error/Report**: #F44336
- **Text**: #FFFFFF (primary), #B0B0B0 (secondary), #1A1A1A (on yellow/light surfaces)

### Typography
- **Arabic**: Noto Kufi Arabic (display/heading), Noto Sans Arabic (body) via Google Fonts
- **French**: Poppins (display/heading), Inter (body) via Google Fonts
- Type scale: Display 32px → Heading 22px → Body 16px → Caption 12px
- Font switches with language toggle

### RTL/LTR
- Arabic: RTL layout direction, right-aligned text
- French: LTR layout direction, left-aligned text
- `I18nManager.forceRTL()` on language switch with app reload
- All layouts use `flexDirection` that respects `I18nManager.isRTL`

### Backgrounds
- Dark gradient from #0F0F0F to #1A1A1A
- Yellow header is solid #FFD600
- Tiffany filter bar is solid #00BCD4
- Cards use glass effect with subtle border (#333)

---

## Animation & Motion

- **Screen transitions**: Slide from right (LTR) or left (RTL) matching language direction
- **Product cards**: Staggered fade-in on scroll (100ms delay between cards)
- **Filter chips**: Scale bounce on select
- **Favorite heart**: Scale up 1.3 with spring + haptic on toggle
- **Image carousel**: Smooth horizontal scroll with momentum
- **Tab switch**: Cross-fade content
- **Pull to refresh**: Custom yellow spinner
- **Skeleton loading**: Shimmer effect on product cards, merchant profiles
- **Button press**: Scale 0.97 with spring
- **Language switch**: Fade out → reload → fade in
- Respect reduced motion preferences

---

## Component Standards

- **Product Card**: Rounded 12px, dark surface, yellow name banner, glass effect border
- **Filter Chips**: Rounded pill, tiffany bg when active, dark outline when inactive
- **Buttons**: Gradient fill matching context (yellow for primary, green for action, tiffany for secondary)
- **Inputs**: Floating labels, dark surface, yellow focus border, error shake
- **Images**: expo-image with blurhash placeholders, fade-in on load
- **Lists**: @shopify/flash-list for product feeds
- **Empty states**: Contextual icon + bilingual message + action button
- **Accessibility**: Contrast ≥ 4.5:1, touch targets 44pt+, Arabic/French accessible labels
- **Spacing**: 8pt grid throughout

---

## Internationalization

- `LocaleProvider` context wrapping entire app
- `useLocale()` hook returns `{locale, t, toggleLocale, isRTL}`
- Translation keys stored in `locales/ar.json` and `locales/fr.json`
- All user-facing strings use `t('key')` — no hardcoded text
- Language toggle persisted to AsyncStorage
- Numbers: Western Arabic numerals in both languages for consistency
