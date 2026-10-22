import React, { useCallback, useState } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet, RefreshControl, FlatList } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useFocusEffect, useRouter } from 'expo-router';
import { COLORS, SPACING, RADIUS, TRADE_TYPE_LABELS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useFilter } from '@/src/contexts/FilterContext';
import { useAuth } from '@/src/contexts/AuthContext';
import { ProductCard } from '@/src/components/ProductCard';
import { productsControllerFindAll, favoritesControllerAdd, favoritesControllerRemove } from '@/src/api/generated/api';
import type { ProductListItemDto } from '@/src/api/generated/schemas';

export default function HomeScreen() {
  const { t, toggleLocale, locale } = useLocale();
  const { user } = useAuth();
  const filter = useFilter();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [products, setProducts] = useState<ProductListItemDto[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [searchVisible, setSearchVisible] = useState(false);
  const [searchText, setSearchText] = useState('');

  const loadProducts = useCallback(async () => {
    try {
      const res = await productsControllerFindAll({
        governorateId: filter.governorateId ?? undefined,
        delegationId: filter.delegationId ?? undefined,
        tradeType: filter.tradeType ?? undefined,
        merchantId: filter.merchantId ?? undefined,
        search: searchText || undefined,
        available: 'true',
        limit: 50,
      });
      setProducts(res?.items ?? []);
    } catch {
      // ignore
    }
  }, [filter.governorateId, filter.delegationId, filter.tradeType, filter.merchantId, searchText]);

  useFocusEffect(useCallback(() => {
    loadProducts();
  }, [loadProducts]));

  const onRefresh = async () => {
    setRefreshing(true);
    await loadProducts();
    setRefreshing(false);
  };

  const toggleFav = async (id: string, current: boolean) => {
    try {
      if (current) {
        await favoritesControllerRemove(id);
      } else {
        await favoritesControllerAdd(id);
      }
      setProducts(prev => prev.map(p => p?.id === id ? { ...p, isFavorited: !current } : p));
    } catch {}
  };

  const filterChips = [
    { label: filter.governorateName ?? t('governorate'), active: !!filter.governorateId },
    { label: filter.delegationName ?? t('delegation'), active: !!filter.delegationId },
    { label: filter.tradeType ? (TRADE_TYPE_LABELS[filter.tradeType]?.[locale] ?? filter.tradeType) : t('tradeType'), active: !!filter.tradeType },
    { label: filter.merchantName ?? t('theMerchant'), active: !!filter.merchantId },
  ];

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + SPACING.sm }]}>
        <Pressable style={styles.langBtn} onPress={toggleLocale}>
          <Text style={styles.langText}>{locale === 'ar' ? 'FR' : '\u0639'}</Text>
        </Pressable>
        <Text style={styles.logo}>{t('appName')}</Text>
        <View style={styles.headerRight}>
          {user?.role === 'merchant' && (
            <Pressable style={styles.merchantBtn} onPress={() => router.push('/add-product')}>
              <Text style={styles.merchantBtnText}>{t('merchant')}</Text>
            </Pressable>
          )}
        </View>
      </View>

      {/* Search bar */}
      {searchVisible && (
        <View style={styles.searchBar}>
          <TextInput
            style={styles.searchInput}
            placeholder={t('search')}
            placeholderTextColor={COLORS.textSecondary}
            value={searchText}
            onChangeText={setSearchText}
            onSubmitEditing={loadProducts}
            returnKeyType="search"
          />
          <Pressable onPress={() => { setSearchVisible(false); setSearchText(''); }}>
            <Ionicons name="close" size={24} color={COLORS.textPrimary} />
          </Pressable>
        </View>
      )}

      {/* Filter bar */}
      <View style={styles.filterBar}>
        <Pressable style={styles.searchIcon} onPress={() => setSearchVisible(!searchVisible)}>
          <Ionicons name="search" size={20} color={COLORS.textOnLight} />
        </Pressable>
        <FlatList
          data={filterChips}
          horizontal
          showsHorizontalScrollIndicator={false}
          keyExtractor={(_, i) => String(i)}
          renderItem={({ item }) => (
            <Pressable
              style={[styles.chip, item.active && styles.chipActive]}
              onPress={() => router.push('/tabs/filter')}
            >
              <Text style={[styles.chipText, item.active && styles.chipTextActive]}>{item.label}</Text>
            </Pressable>
          )}
          contentContainerStyle={styles.chipList}
        />
      </View>

      {/* Products */}
      <FlatList
        data={products ?? []}
        keyExtractor={item => item?.id ?? ''}
        renderItem={({ item }) => <ProductCard product={item} onToggleFavorite={toggleFav} />}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="basket-outline" size={48} color={COLORS.textSecondary} />
            <Text style={styles.emptyText}>{t('noProducts')}</Text>
          </View>
        }
      />

      {/* FAB for merchants */}
      {user?.role === 'merchant' && (
        <Pressable style={[styles.fab, { bottom: SPACING.lg }]} onPress={() => router.push('/add-product')}>
          <Ionicons name="add" size={28} color="#fff" />
        </Pressable>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: {
    backgroundColor: COLORS.primary, flexDirection: 'row', alignItems: 'center',
    justifyContent: 'center', paddingBottom: SPACING.sm, paddingHorizontal: SPACING.md,
  },
  langBtn: {
    position: 'absolute', left: SPACING.md, bottom: SPACING.sm,
    backgroundColor: '#999', paddingHorizontal: SPACING.sm, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm,
  },
  langText: { color: COLORS.textOnLight, fontWeight: 'bold', fontSize: 13 },
  logo: { fontSize: 28, fontWeight: 'bold', color: COLORS.textOnLight },
  headerRight: { position: 'absolute', right: SPACING.md, bottom: SPACING.sm, flexDirection: 'row', gap: SPACING.xs },
  merchantBtn: { backgroundColor: COLORS.action, paddingHorizontal: SPACING.sm, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm },
  merchantBtnText: { color: '#fff', fontWeight: 'bold', fontSize: 12 },
  searchBar: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: COLORS.surface,
    paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs,
  },
  searchInput: { flex: 1, color: COLORS.textPrimary, fontSize: 16, paddingVertical: SPACING.xs },
  filterBar: {
    backgroundColor: COLORS.secondary, flexDirection: 'row', alignItems: 'center',
    paddingVertical: SPACING.xs, paddingHorizontal: SPACING.xs,
  },
  searchIcon: { padding: SPACING.xs },
  chipList: { paddingHorizontal: SPACING.xs, gap: SPACING.xs },
  chip: {
    backgroundColor: 'rgba(255,255,255,0.2)', paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs,
    borderRadius: RADIUS.full, borderWidth: 1, borderColor: 'rgba(255,255,255,0.3)',
  },
  chipActive: { backgroundColor: COLORS.primary, borderColor: COLORS.primary },
  chipText: { color: '#fff', fontSize: 13, fontWeight: '600' },
  chipTextActive: { color: COLORS.textOnLight },
  list: { paddingTop: SPACING.md, paddingBottom: 80 },
  empty: { alignItems: 'center', paddingTop: 80 },
  emptyText: { color: COLORS.textSecondary, fontSize: 16, marginTop: SPACING.md },
  fab: {
    position: 'absolute', right: SPACING.md,
    backgroundColor: COLORS.action, width: 56, height: 56, borderRadius: 28,
    justifyContent: 'center', alignItems: 'center', elevation: 4,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.3, shadowRadius: 4,
  },
});
