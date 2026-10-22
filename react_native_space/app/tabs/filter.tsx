import React, { useState, useEffect } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView, FlatList } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { COLORS, SPACING, RADIUS, TRADE_TYPES, TRADE_TYPE_LABELS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useFilter } from '@/src/contexts/FilterContext';
import { governoratesControllerFindAll, governoratesControllerFindDelegations } from '@/src/api/generated/api';
import type { GovernorateItemDto, DelegationItemDto } from '@/src/api/generated/schemas';

export default function FilterScreen() {
  const { t, locale } = useLocale();
  const filter = useFilter();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [govs, setGovs] = useState<GovernorateItemDto[]>([]);
  const [dels, setDels] = useState<DelegationItemDto[]>([]);

  useEffect(() => {
    governoratesControllerFindAll().then(r => setGovs(r?.items ?? [])).catch(() => {});
  }, []);

  useEffect(() => {
    if (filter.governorateId) {
      governoratesControllerFindDelegations(filter.governorateId).then(r => setDels(r?.items ?? [])).catch(() => {});
    } else {
      setDels([]);
    }
  }, [filter.governorateId]);

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('filter')}</Text>
        <Pressable onPress={() => { filter.clearAll(); }}>
          <Text style={styles.clearText}>{t('clear')}</Text>
        </Pressable>
      </View>

      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        {/* Governorates */}
        <Text style={styles.sectionTitle}>{t('governorate')}</Text>
        <FlatList
          data={govs}
          scrollEnabled={false}
          keyExtractor={item => item?.id ?? ''}
          renderItem={({ item }) => (
            <Pressable
              style={[styles.listItem, filter.governorateId === item?.id && styles.listItemActive]}
              onPress={() => filter.setGovernorate(
                filter.governorateId === item?.id ? null : (item?.id ?? null),
                filter.governorateId === item?.id ? null : (locale === 'ar' ? item?.nameAr : item?.nameFr) ?? null,
              )}
            >
              <Text style={styles.listItemText}>
                {locale === 'ar' ? item?.nameAr : item?.nameFr}
              </Text>
              {filter.governorateId === item?.id && <Ionicons name="checkmark" size={20} color={COLORS.primary} />}
            </Pressable>
          )}
        />

        {/* Delegations */}
        {filter.governorateId && dels.length > 0 && (
          <>
            <Text style={styles.sectionTitle}>{t('delegation')}</Text>
            <FlatList
              data={dels}
              scrollEnabled={false}
              keyExtractor={item => item?.id ?? ''}
              renderItem={({ item }) => (
                <Pressable
                  style={[styles.listItem, filter.delegationId === item?.id && styles.listItemActive]}
                  onPress={() => filter.setDelegation(
                    filter.delegationId === item?.id ? null : (item?.id ?? null),
                    filter.delegationId === item?.id ? null : (locale === 'ar' ? item?.nameAr : item?.nameFr) ?? null,
                  )}
                >
                  <Text style={styles.listItemText}>
                    {locale === 'ar' ? item?.nameAr : item?.nameFr}
                  </Text>
                  {filter.delegationId === item?.id && <Ionicons name="checkmark" size={20} color={COLORS.primary} />}
                </Pressable>
              )}
            />
          </>
        )}

        {/* Trade Type */}
        <Text style={styles.sectionTitle}>{t('tradeType')}</Text>
        <View style={styles.tradeGrid}>
          {TRADE_TYPES.map(tt => (
            <Pressable
              key={tt}
              style={[styles.tradeChip, filter.tradeType === tt && styles.tradeChipActive]}
              onPress={() => filter.setTradeType(filter.tradeType === tt ? null : tt)}
            >
              <Text style={[styles.tradeChipText, filter.tradeType === tt && styles.tradeChipTextActive]}>
                {TRADE_TYPE_LABELS[tt]?.[locale] ?? tt}
              </Text>
            </Pressable>
          ))}
        </View>
      </ScrollView>

      <Pressable style={styles.applyBtn} onPress={() => router.push('/tabs')}>
        <Text style={styles.applyBtnText}>{t('apply')}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: SPACING.md, paddingVertical: SPACING.md },
  title: { fontSize: 24, fontWeight: 'bold', color: COLORS.textPrimary },
  clearText: { color: COLORS.error, fontSize: 14, fontWeight: '600' },
  scroll: { flex: 1 },
  scrollContent: { paddingHorizontal: SPACING.md, paddingBottom: 100 },
  sectionTitle: { fontSize: 18, fontWeight: 'bold', color: COLORS.primary, marginTop: SPACING.lg, marginBottom: SPACING.sm },
  listItem: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingVertical: SPACING.sm, paddingHorizontal: SPACING.md,
    backgroundColor: COLORS.surface, borderRadius: RADIUS.sm, marginBottom: SPACING.xs,
  },
  listItemActive: { borderColor: COLORS.primary, borderWidth: 1 },
  listItemText: { color: COLORS.textPrimary, fontSize: 15 },
  tradeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: SPACING.sm },
  tradeChip: {
    paddingHorizontal: SPACING.md, paddingVertical: SPACING.sm,
    backgroundColor: COLORS.surface, borderRadius: RADIUS.full, borderWidth: 1, borderColor: COLORS.surfaceElevated,
  },
  tradeChipActive: { backgroundColor: COLORS.secondary, borderColor: COLORS.secondary },
  tradeChipText: { color: COLORS.textSecondary, fontSize: 14 },
  tradeChipTextActive: { color: '#fff' },
  applyBtn: {
    position: 'absolute', bottom: SPACING.lg, left: SPACING.md, right: SPACING.md,
    backgroundColor: COLORS.action, padding: SPACING.md, borderRadius: RADIUS.md, alignItems: 'center',
  },
  applyBtnText: { color: '#fff', fontWeight: 'bold', fontSize: 16 },
});
