import React, { useState, useCallback } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView, FlatList, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS, TRADE_TYPE_LABELS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useAuth } from '@/src/contexts/AuthContext';
import { merchantsControllerFindOne, productsControllerFindMine, productsControllerRemove } from '@/src/api/generated/api';
import type { MerchantResponseDto, ProductListItemDto } from '@/src/api/generated/schemas';
import { ProductCard } from '@/src/components/ProductCard';

export default function ProfileScreen() {
  const { t, locale } = useLocale();
  const { user, logout } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [merchant, setMerchant] = useState<MerchantResponseDto | null>(null);
  const [myProducts, setMyProducts] = useState<ProductListItemDto[]>([]);
  const [showProducts, setShowProducts] = useState(false);

  useFocusEffect(useCallback(() => {
    if (user?.role === 'merchant') {
      // We need to get the merchant profile - but we need merchant ID. Use auth/me approach
      // Actually we can use products/mine endpoint
      productsControllerFindMine({}).then(r => setMyProducts(r?.items ?? [])).catch(() => {});
    }
  }, [user]));

  const handleDelete = async (productId: string) => {
    try {
      await productsControllerRemove(productId);
      setMyProducts(prev => prev.filter(p => p?.id !== productId));
    } catch {}
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('profile')}</Text>
      </View>
      <ScrollView contentContainerStyle={styles.content}>
        {/* User info */}
        <View style={styles.card}>
          <Ionicons name="person-circle" size={64} color={COLORS.primary} />
          <Text style={styles.name}>{user?.name ?? ''}</Text>
          <Text style={styles.email}>{user?.email ?? ''}</Text>
          <View style={[styles.roleBadge, { backgroundColor: user?.role === 'merchant' ? COLORS.action : COLORS.secondary }]}>
            <Text style={styles.roleText}>{user?.role === 'merchant' ? t('merchant') : t('visitor')}</Text>
          </View>
        </View>

        {/* Merchant section */}
        {user?.role === 'merchant' && (
          <>
            <Pressable style={styles.menuItem} onPress={() => router.push('/merchant-setup')}>
              <Ionicons name="settings-outline" size={22} color={COLORS.primary} />
              <Text style={styles.menuText}>{t('editShop')}</Text>
              <Ionicons name="chevron-forward" size={20} color={COLORS.textSecondary} />
            </Pressable>

            <Pressable style={styles.menuItem} onPress={() => setShowProducts(!showProducts)}>
              <Ionicons name="cube-outline" size={22} color={COLORS.primary} />
              <Text style={styles.menuText}>{t('myProducts')} ({myProducts?.length ?? 0})</Text>
              <Ionicons name={showProducts ? 'chevron-up' : 'chevron-down'} size={20} color={COLORS.textSecondary} />
            </Pressable>

            {showProducts && (
              <FlatList
                data={myProducts ?? []}
                scrollEnabled={false}
                keyExtractor={item => item?.id ?? ''}
                renderItem={({ item }) => (
                  <View>
                    <ProductCard product={item} />
                    <View style={styles.productActions}>
                      <Pressable style={styles.editBtn} onPress={() => router.push(`/product/${item?.id}/edit`)}>
                        <Ionicons name="pencil" size={16} color="#fff" />
                        <Text style={styles.actionText}>{t('edit')}</Text>
                      </Pressable>
                      <Pressable style={styles.deleteBtn} onPress={() => handleDelete(item?.id ?? '')}>
                        <Ionicons name="trash" size={16} color="#fff" />
                        <Text style={styles.actionText}>{t('delete')}</Text>
                      </Pressable>
                    </View>
                  </View>
                )}
              />
            )}
          </>
        )}

        <Pressable style={styles.menuItem} onPress={() => router.push('/dashboard')}>
          <Ionicons name="stats-chart-outline" size={22} color={COLORS.primary} />
          <Text style={styles.menuText}>{t('stats')}</Text>
          <Ionicons name="chevron-forward" size={20} color={COLORS.textSecondary} />
        </Pressable>

        <Pressable style={styles.logoutBtn} onPress={logout}>
          <Ionicons name="log-out-outline" size={22} color={COLORS.error} />
          <Text style={styles.logoutText}>{t('logout')}</Text>
        </Pressable>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, padding: SPACING.md, alignItems: 'center' },
  title: { fontSize: 22, fontWeight: 'bold', color: COLORS.textOnLight },
  content: { padding: SPACING.md, paddingBottom: 40 },
  card: {
    backgroundColor: COLORS.surface, borderRadius: RADIUS.lg, padding: SPACING.lg,
    alignItems: 'center', marginBottom: SPACING.md,
  },
  name: { fontSize: 20, fontWeight: 'bold', color: COLORS.textPrimary, marginTop: SPACING.sm },
  email: { fontSize: 14, color: COLORS.textSecondary, marginTop: SPACING.xs },
  roleBadge: { marginTop: SPACING.sm, paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.full },
  roleText: { color: '#fff', fontWeight: 'bold', fontSize: 13 },
  menuItem: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: COLORS.surface,
    padding: SPACING.md, borderRadius: RADIUS.md, marginBottom: SPACING.sm, gap: SPACING.md,
  },
  menuText: { flex: 1, color: COLORS.textPrimary, fontSize: 16 },
  productActions: {
    flexDirection: 'row', justifyContent: 'flex-end', gap: SPACING.sm,
    marginHorizontal: SPACING.md, marginTop: -SPACING.sm, marginBottom: SPACING.md,
  },
  editBtn: { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: COLORS.secondary, paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm },
  deleteBtn: { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: COLORS.error, paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm },
  actionText: { color: '#fff', fontSize: 13, fontWeight: '600' },
  logoutBtn: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.sm,
    padding: SPACING.md, borderRadius: RADIUS.md, borderWidth: 1, borderColor: COLORS.error, marginTop: SPACING.lg,
  },
  logoutText: { color: COLORS.error, fontSize: 16, fontWeight: 'bold' },
});
