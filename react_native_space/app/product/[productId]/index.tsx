import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView, Image, Linking, Dimensions, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useAuth } from '@/src/contexts/AuthContext';
import {
  productsControllerFindOne,
  productsControllerIncrementView,
  favoritesControllerAdd,
  favoritesControllerRemove,
} from '@/src/api/generated/api';
import type { ProductDetailResponseDto } from '@/src/api/generated/schemas';

const { width: SCREEN_W } = Dimensions.get('window');

export default function ProductDetailScreen() {
  const { productId = '' } = useLocalSearchParams<{ productId: string }>();
  const { t, locale } = useLocale();
  const { user } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [product, setProduct] = useState<ProductDetailResponseDto | null>(null);
  const [loading, setLoading] = useState(true);
  const [imgIdx, setImgIdx] = useState(0);
  const [fav, setFav] = useState(false);

  useEffect(() => {
    if (!productId) return;
    (async () => {
      try {
        const res = await productsControllerFindOne(productId);
        setProduct(res ?? null);
        setFav(res?.isFavorited ?? false);
        productsControllerIncrementView(productId).catch(() => {});
      } catch {} finally { setLoading(false); }
    })();
  }, [productId]);

  const toggleFav = async () => {
    try {
      if (fav) { await favoritesControllerRemove(productId); }
      else { await favoritesControllerAdd(productId); }
      setFav(!fav);
    } catch {}
  };

  const handleCall = () => {
    const num = product?.phone ?? '';
    if (num) Linking.openURL(`tel:${num}`);
  };

  if (loading) return <View style={[styles.container, { paddingTop: insets.top, justifyContent: 'center', alignItems: 'center' }]}><ActivityIndicator size="large" color={COLORS.primary} /></View>;
  if (!product) return <View style={[styles.container, { paddingTop: insets.top, justifyContent: 'center', alignItems: 'center' }]}><Text style={{ color: COLORS.textSecondary }}>Not found</Text></View>;

  const imgs = product?.images ?? [];
  const currentImg = imgs?.[imgIdx];

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
        <Text style={styles.headerTitle} numberOfLines={1}>{product?.name ?? ''}</Text>
        <Pressable onPress={toggleFav}><Ionicons name={fav ? 'heart' : 'heart-outline'} size={26} color={fav ? COLORS.error : COLORS.textOnLight} /></Pressable>
      </View>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Image gallery */}
        <View style={styles.gallery}>
          {currentImg?.url ? (
            <Image source={{ uri: currentImg.url }} style={styles.mainImage} resizeMode="cover" />
          ) : (
            <View style={[styles.mainImage, styles.placeholder]}><Ionicons name="image-outline" size={64} color={COLORS.textSecondary} /></View>
          )}
          {imgs.length > 1 && (
            <ScrollView horizontal style={styles.thumbRow} showsHorizontalScrollIndicator={false}>
              {imgs.map((img, i) => (
                <Pressable key={img?.id ?? i} onPress={() => setImgIdx(i)}>
                  <Image source={{ uri: img?.url ?? '' }} style={[styles.thumb, imgIdx === i && styles.thumbActive]} />
                </Pressable>
              ))}
            </ScrollView>
          )}
        </View>

        {/* Info */}
        <View style={styles.infoSection}>
          <Text style={styles.productName}>{product?.name ?? ''}</Text>
          <Text style={styles.price}>{product?.price?.toFixed?.(2) ?? '0'} {t('tnd')}</Text>
          <View style={[styles.badge, product?.isAvailable ? styles.badgeAvail : styles.badgeExp]}>
            <Text style={styles.badgeText}>{product?.isAvailable ? t('available') : t('expired')}</Text>
          </View>
        </View>

        {product?.description ? <Text style={styles.desc}>{product.description}</Text> : null}

        <View style={styles.meta}>
          <View style={styles.metaRow}><Ionicons name="eye-outline" size={18} color={COLORS.textSecondary} /><Text style={styles.metaText}>{product?.viewCount ?? 0} {t('views')}</Text></View>
          <View style={styles.metaRow}><Ionicons name="call-outline" size={18} color={COLORS.textSecondary} /><Text style={styles.metaText}>{product?.phone ?? ''}</Text></View>
          <View style={styles.metaRow}><Ionicons name="calendar-outline" size={18} color={COLORS.textSecondary} /><Text style={styles.metaText}>{t('expiryDate')}: {new Date(product?.expiryDate ?? '').toLocaleDateString(locale === 'ar' ? 'ar-TN' : 'fr-TN')}</Text></View>
        </View>

        {/* Merchant info */}
        <Pressable style={styles.merchantCard} onPress={() => router.push(`/merchant/${product?.merchant?.id}`)}>
          <Ionicons name="storefront-outline" size={28} color={COLORS.primary} />
          <View style={{ flex: 1 }}>
            <Text style={styles.merchantName}>{product?.merchant?.shopName ?? t('theMerchant')}</Text>
            <View style={styles.ratingRow}>
              <Ionicons name="star" size={14} color={COLORS.primary} />
              <Text style={styles.ratingText}>{product?.merchant?.averageRating?.toFixed?.(1) ?? '0'}</Text>
            </View>
          </View>
          <Ionicons name="chevron-forward" size={22} color={COLORS.textSecondary} />
        </Pressable>

        {/* Call button */}
        <Pressable style={styles.callBtn} onPress={handleCall}>
          <Ionicons name="call" size={22} color="#fff" />
          <Text style={styles.callBtnText}>{t('call')}</Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: SPACING.md },
  backBtn: { padding: SPACING.xs },
  headerTitle: { flex: 1, fontSize: 18, fontWeight: 'bold', color: COLORS.textOnLight, textAlign: 'center', marginHorizontal: SPACING.sm },
  content: { paddingBottom: 60 },
  gallery: { backgroundColor: COLORS.surface },
  mainImage: { width: SCREEN_W, height: SCREEN_W * 0.75 },
  placeholder: { justifyContent: 'center', alignItems: 'center', backgroundColor: COLORS.surfaceElevated },
  thumbRow: { paddingVertical: SPACING.sm, paddingHorizontal: SPACING.md },
  thumb: { width: 56, height: 56, borderRadius: RADIUS.sm, marginRight: SPACING.sm, borderWidth: 2, borderColor: 'transparent' },
  thumbActive: { borderColor: COLORS.primary },
  infoSection: { padding: SPACING.md },
  productName: { fontSize: 22, fontWeight: 'bold', color: COLORS.textPrimary },
  price: { fontSize: 24, fontWeight: 'bold', color: COLORS.action, marginTop: SPACING.xs },
  badge: { alignSelf: 'flex-start', paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.full, marginTop: SPACING.sm },
  badgeAvail: { backgroundColor: COLORS.action },
  badgeExp: { backgroundColor: COLORS.error },
  badgeText: { color: '#fff', fontSize: 13, fontWeight: 'bold' },
  desc: { color: COLORS.textSecondary, fontSize: 15, lineHeight: 22, paddingHorizontal: SPACING.md, marginBottom: SPACING.md },
  meta: { paddingHorizontal: SPACING.md, marginBottom: SPACING.md, gap: SPACING.sm },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: SPACING.sm },
  metaText: { color: COLORS.textSecondary, fontSize: 14 },
  merchantCard: { flexDirection: 'row', alignItems: 'center', backgroundColor: COLORS.surface, marginHorizontal: SPACING.md, padding: SPACING.md, borderRadius: RADIUS.md, gap: SPACING.md },
  merchantName: { color: COLORS.textPrimary, fontSize: 16, fontWeight: '600' },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 2 },
  ratingText: { color: COLORS.primary, fontSize: 13 },
  callBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.sm, backgroundColor: COLORS.action, margin: SPACING.md, padding: SPACING.md, borderRadius: RADIUS.md },
  callBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
});
