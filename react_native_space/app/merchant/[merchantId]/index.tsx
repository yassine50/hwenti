import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView, FlatList, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter, useFocusEffect } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS, TRADE_TYPE_LABELS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useAuth } from '@/src/contexts/AuthContext';
import {
  merchantsControllerFindOne,
  productsControllerFindAll,
  followsControllerFollow,
  followsControllerUnfollow,
  ratingsControllerFindAll,
  ratingsControllerCreate,
} from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';
import type { MerchantResponseDto, ProductListItemDto, RatingItemDto } from '@/src/api/generated/schemas';
import { ProductCard } from '@/src/components/ProductCard';

export default function MerchantProfileScreen() {
  const { merchantId = '' } = useLocalSearchParams<{ merchantId: string }>();
  const { t, locale } = useLocale();
  const { user } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [merchant, setMerchant] = useState<MerchantResponseDto | null>(null);
  const [products, setProducts] = useState<ProductListItemDto[]>([]);
  const [ratings, setRatings] = useState<RatingItemDto[]>([]);
  const [avgRating, setAvgRating] = useState(0);
  const [isFollowing, setIsFollowing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [myScore, setMyScore] = useState(0);
  const [ratingLoading, setRatingLoading] = useState(false);

  const loadData = useCallback(async () => {
    if (!merchantId) return;
    try {
      const [m, p, r] = await Promise.all([
        merchantsControllerFindOne(merchantId),
        productsControllerFindAll({ merchantId, available: 'true', limit: 50 }),
        ratingsControllerFindAll(merchantId, {}),
      ]);
      setMerchant(m ?? null);
      setProducts(p?.items ?? []);
      setRatings(r?.items ?? []);
      setAvgRating(r?.average ?? 0);
    } catch {} finally { setLoading(false); }
  }, [merchantId]);

  useFocusEffect(useCallback(() => { loadData(); }, [loadData]));

  const handleFollow = async () => {
    try {
      if (isFollowing) { await followsControllerUnfollow(merchantId); }
      else { await followsControllerFollow(merchantId); }
      setIsFollowing(!isFollowing);
    } catch {}
  };

  const handleRate = async (score: number) => {
    if (!score) return;
    setRatingLoading(true);
    try {
      await ratingsControllerCreate(merchantId, { score });
      setMyScore(score);
      await loadData();
    } catch {} finally { setRatingLoading(false); }
  };

  if (loading) return <View style={[styles.container, { paddingTop: insets.top, justifyContent: 'center', alignItems: 'center' }]}><ActivityIndicator size="large" color={COLORS.primary} /></View>;

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
        <Text style={styles.headerTitle} numberOfLines={1}>{merchant?.shopName ?? t('theMerchant')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Merchant info card */}
        <View style={styles.card}>
          <Ionicons name="storefront" size={48} color={COLORS.primary} />
          <Text style={styles.shopName}>{merchant?.shopName ?? ''}</Text>
          {merchant?.tradeType ? (
            <Text style={styles.tradeType}>{TRADE_TYPE_LABELS[merchant.tradeType]?.[locale] ?? merchant.tradeType}</Text>
          ) : null}
          <Text style={styles.location}>
            {merchant?.governorateName ?? ''}{merchant?.delegationName ? ` - ${merchant.delegationName}` : ''}
          </Text>
          <View style={styles.ratingRow}>
            <Ionicons name="star" size={20} color={COLORS.primary} />
            <Text style={styles.ratingBig}>{avgRating?.toFixed?.(1) ?? '0'}</Text>
            <Text style={styles.ratingCount}>({merchant?.ratingCount ?? 0})</Text>
          </View>
        </View>

        {/* Actions row */}
        <View style={styles.actionsRow}>
          <Pressable style={[styles.actionBtn, isFollowing && styles.actionBtnActive]} onPress={handleFollow}>
            <Ionicons name={isFollowing ? 'checkmark-circle' : 'add-circle-outline'} size={20} color={isFollowing ? '#fff' : COLORS.secondary} />
            <Text style={[styles.actionBtnText, isFollowing && { color: '#fff' }]}>{isFollowing ? t('unfollow') : t('follow')}</Text>
          </Pressable>
          <Pressable style={styles.actionBtn} onPress={() => router.push(`/merchant/${merchantId}/report`)}>
            <Ionicons name="flag-outline" size={20} color={COLORS.error} />
            <Text style={styles.actionBtnText}>{t('report')}</Text>
          </Pressable>
        </View>

        {/* Rate */}
        <View style={styles.rateSection}>
          <Text style={styles.sectionTitle}>{locale === 'ar' ? 'قيّم هذا التاجر' : 'Évaluer ce marchand'}</Text>
          <View style={styles.starsRow}>
            {[1, 2, 3, 4, 5].map(s => (
              <Pressable key={s} onPress={() => handleRate(s)} disabled={ratingLoading}>
                <Ionicons name={s <= myScore ? 'star' : 'star-outline'} size={32} color={COLORS.primary} />
              </Pressable>
            ))}
          </View>
        </View>

        {/* Reviews */}
        {(ratings?.length ?? 0) > 0 && (
          <View style={styles.reviewsSection}>
            <Text style={styles.sectionTitle}>{locale === 'ar' ? 'التقييمات' : 'Évaluations'}</Text>
            {(ratings ?? []).slice(0, 10).map(r => (
              <View key={r?.id} style={styles.reviewItem}>
                <View style={styles.reviewHeader}>
                  <Text style={styles.reviewerName}>{r?.userName ?? ''}</Text>
                  <View style={{ flexDirection: 'row' }}>
                    {[1, 2, 3, 4, 5].map(s => (
                      <Ionicons key={s} name={s <= (r?.score ?? 0) ? 'star' : 'star-outline'} size={14} color={COLORS.primary} />
                    ))}
                  </View>
                </View>
                <Text style={styles.reviewDate}>{new Date(r?.createdAt ?? '').toLocaleDateString()}</Text>
              </View>
            ))}
          </View>
        )}

        {/* Products */}
        <Text style={[styles.sectionTitle, { paddingHorizontal: SPACING.md }]}>{t('myProducts')} ({products?.length ?? 0})</Text>
        {(products ?? []).map(p => <ProductCard key={p?.id} product={p} />)}
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
  card: { backgroundColor: COLORS.surface, borderRadius: RADIUS.lg, margin: SPACING.md, padding: SPACING.lg, alignItems: 'center' },
  shopName: { fontSize: 22, fontWeight: 'bold', color: COLORS.textPrimary, marginTop: SPACING.sm },
  tradeType: { color: COLORS.secondary, fontSize: 14, marginTop: SPACING.xs },
  location: { color: COLORS.textSecondary, fontSize: 14, marginTop: SPACING.xs },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: SPACING.xs, marginTop: SPACING.sm },
  ratingBig: { fontSize: 20, fontWeight: 'bold', color: COLORS.primary },
  ratingCount: { color: COLORS.textSecondary, fontSize: 14 },
  actionsRow: { flexDirection: 'row', justifyContent: 'center', gap: SPACING.md, marginHorizontal: SPACING.md, marginBottom: SPACING.md },
  actionBtn: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.xs, backgroundColor: COLORS.surface, padding: SPACING.md, borderRadius: RADIUS.md },
  actionBtnActive: { backgroundColor: COLORS.secondary },
  actionBtnText: { color: COLORS.textPrimary, fontSize: 14, fontWeight: '600' },
  rateSection: { paddingHorizontal: SPACING.md, marginBottom: SPACING.md },
  sectionTitle: { color: COLORS.textPrimary, fontSize: 17, fontWeight: 'bold', marginBottom: SPACING.sm },
  starsRow: { flexDirection: 'row', gap: SPACING.sm },
  reviewsSection: { paddingHorizontal: SPACING.md, marginBottom: SPACING.md },
  reviewItem: { backgroundColor: COLORS.surface, borderRadius: RADIUS.sm, padding: SPACING.md, marginBottom: SPACING.sm },
  reviewHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  reviewerName: { color: COLORS.textPrimary, fontSize: 14, fontWeight: '600' },
  reviewDate: { color: COLORS.textSecondary, fontSize: 12, marginTop: 2 },
});
