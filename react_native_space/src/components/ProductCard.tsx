import React from 'react';
import { View, Text, Pressable, Image, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import type { ProductListItemDto } from '@/src/api/generated/schemas';

interface Props {
  product: ProductListItemDto;
  onToggleFavorite?: (id: string, current: boolean) => void;
}

export function ProductCard({ product, onToggleFavorite }: Props) {
  const router = useRouter();
  const { t } = useLocale();

  return (
    <Pressable
      style={styles.card}
      onPress={() => router.push(`/product/${product?.id}`)}
    >
      <View style={styles.imageContainer}>
        {product?.primaryImageUrl ? (
          <Image source={{ uri: product.primaryImageUrl }} style={styles.image} resizeMode="cover" />
        ) : (
          <View style={[styles.image, styles.placeholder]}>
            <Ionicons name="image-outline" size={48} color={COLORS.textSecondary} />
          </View>
        )}
        <View style={styles.nameBanner}>
          <Text style={styles.nameText} numberOfLines={1}>{product?.name ?? ''}</Text>
        </View>
        {onToggleFavorite && (
          <Pressable
            style={styles.heartBtn}
            onPress={() => onToggleFavorite?.(product?.id ?? '', product?.isFavorited ?? false)}
          >
            <Ionicons
              name={product?.isFavorited ? 'heart' : 'heart-outline'}
              size={24}
              color={product?.isFavorited ? COLORS.error : COLORS.textPrimary}
            />
          </Pressable>
        )}
      </View>
      <View style={styles.infoRow}>
        <Text style={styles.price}>{product?.price?.toFixed?.(2) ?? '0'} {t('tnd')}</Text>
        <View style={styles.viewsRow}>
          <Ionicons name="eye-outline" size={14} color={COLORS.textSecondary} />
          <Text style={styles.viewCount}>{product?.viewCount ?? 0}</Text>
        </View>
      </View>
      <View style={styles.bottomRow}>
        <Text style={styles.merchantName} numberOfLines={1}>{product?.merchant?.shopName ?? ''}</Text>
        <View style={styles.ratingRow}>
          <Ionicons name="star" size={14} color={COLORS.primary} />
          <Text style={styles.ratingText}>{product?.merchant?.averageRating?.toFixed?.(1) ?? '0'}</Text>
        </View>
      </View>
      <View style={[styles.badge, product?.isAvailable ? styles.badgeAvailable : styles.badgeExpired]}>
        <Text style={styles.badgeText}>{product?.isAvailable ? t('available') : t('expired')}</Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.surface,
    borderRadius: RADIUS.md,
    marginHorizontal: SPACING.md,
    marginBottom: SPACING.md,
    overflow: 'hidden',
  },
  imageContainer: { position: 'relative', aspectRatio: 4 / 3 },
  image: { width: '100%', height: '100%' },
  placeholder: { backgroundColor: COLORS.surfaceElevated, justifyContent: 'center', alignItems: 'center' },
  nameBanner: {
    position: 'absolute', bottom: 0, left: 0, right: 0,
    backgroundColor: COLORS.primary, paddingHorizontal: SPACING.md, paddingVertical: SPACING.sm,
  },
  nameText: { color: COLORS.textOnLight, fontSize: 18, fontWeight: 'bold' },
  heartBtn: { position: 'absolute', top: SPACING.sm, right: SPACING.sm, padding: SPACING.xs },
  infoRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingHorizontal: SPACING.md, paddingTop: SPACING.sm,
  },
  price: { color: COLORS.action, fontSize: 18, fontWeight: 'bold' },
  viewsRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  viewCount: { color: COLORS.textSecondary, fontSize: 12 },
  bottomRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingHorizontal: SPACING.md, paddingBottom: SPACING.sm, paddingTop: SPACING.xs,
  },
  merchantName: { color: COLORS.textSecondary, fontSize: 14, flex: 1 },
  ratingRow: { flexDirection: 'row', alignItems: 'center', gap: 2 },
  ratingText: { color: COLORS.primary, fontSize: 13, fontWeight: '600' },
  badge: {
    position: 'absolute', top: SPACING.sm, left: SPACING.sm,
    paddingHorizontal: SPACING.sm, paddingVertical: 2, borderRadius: RADIUS.sm,
  },
  badgeAvailable: { backgroundColor: COLORS.action },
  badgeExpired: { backgroundColor: COLORS.error },
  badgeText: { color: '#fff', fontSize: 11, fontWeight: 'bold' },
});
