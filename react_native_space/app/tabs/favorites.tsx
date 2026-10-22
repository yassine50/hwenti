import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { ProductCard } from '@/src/components/ProductCard';
import { favoritesControllerFindAll, favoritesControllerRemove } from '@/src/api/generated/api';
import type { ProductListItemDto } from '@/src/api/generated/schemas';

export default function FavoritesScreen() {
  const { t } = useLocale();
  const insets = useSafeAreaInsets();
  const [items, setItems] = useState<ProductListItemDto[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    try {
      const res = await favoritesControllerFindAll({});
      setItems(res?.items ?? []);
    } catch {}
  }, []);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  const onRemove = async (id: string) => {
    try {
      await favoritesControllerRemove(id);
      setItems(prev => prev.filter(p => p?.id !== id));
    } catch {}
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('favorites')}</Text>
      </View>
      <FlatList
        data={items ?? []}
        keyExtractor={item => item?.id ?? ''}
        renderItem={({ item }) => (
          <ProductCard product={item} onToggleFavorite={(id) => onRemove(id)} />
        )}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={async () => { setRefreshing(true); await load(); setRefreshing(false); }} tintColor={COLORS.primary} />}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="heart-outline" size={48} color={COLORS.textSecondary} />
            <Text style={styles.emptyText}>{t('noFavorites')}</Text>
          </View>
        }
        contentContainerStyle={styles.list}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, padding: SPACING.md, alignItems: 'center' },
  title: { fontSize: 22, fontWeight: 'bold', color: COLORS.textOnLight },
  list: { paddingTop: SPACING.md, paddingBottom: 20 },
  empty: { alignItems: 'center', paddingTop: 80 },
  emptyText: { color: COLORS.textSecondary, fontSize: 16, marginTop: SPACING.md },
});
