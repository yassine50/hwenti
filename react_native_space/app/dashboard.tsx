import React, { useEffect, useState } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { visitorStatsControllerSummary } from '@/src/api/generated/api';
import type { VisitorStatsSummaryResponseDto, GovStatDto, DelStatDto } from '@/src/api/generated/schemas';

export default function DashboardScreen() {
  const { t, locale } = useLocale();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [data, setData] = useState<VisitorStatsSummaryResponseDto | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    visitorStatsControllerSummary().then(r => setData(r ?? null)).catch(() => {}).finally(() => setLoading(false));
  }, []);

  if (loading) return <View style={[styles.container, { paddingTop: insets.top, justifyContent: 'center', alignItems: 'center' }]}><ActivityIndicator size="large" color={COLORS.primary} /></View>;

  const govStats: GovStatDto[] = data?.byGovernorate ?? [];
  const delStats: DelStatDto[] = data?.byDelegation ?? [];
  const maxGov = Math.max(...govStats.map(g => g?.count ?? 0), 1);

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
        <Text style={styles.headerTitle}>{t('stats')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Total card */}
        <View style={styles.totalCard}>
          <Ionicons name="people" size={40} color={COLORS.primary} />
          <Text style={styles.totalLabel}>{t('totalVisitors')}</Text>
          <Text style={styles.totalNumber}>{data?.totalVisitors ?? 0}</Text>
        </View>

        {/* By governorate */}
        <Text style={styles.sectionTitle}>{locale === 'ar' ? 'حسب الولاية' : 'Par gouvernorat'}</Text>
        {govStats.length === 0 && <Text style={styles.empty}>{locale === 'ar' ? 'لا توجد بيانات' : 'Aucune donnée'}</Text>}
        {govStats.map(g => (
          <View key={g?.governorateId ?? ''} style={styles.barRow}>
            <Text style={styles.barLabel} numberOfLines={1}>{g?.governorateName ?? ''}</Text>
            <View style={styles.barTrack}>
              <View style={[styles.barFill, { width: `${Math.max(((g?.count ?? 0) / maxGov) * 100, 2)}%` }]} />
            </View>
            <Text style={styles.barCount}>{g?.count ?? 0}</Text>
          </View>
        ))}

        {/* By delegation */}
        {delStats.length > 0 && (
          <>
            <Text style={[styles.sectionTitle, { marginTop: SPACING.lg }]}>{locale === 'ar' ? 'حسب المعتمدية' : 'Par délégation'}</Text>
            {delStats.map(d => (
              <View key={d?.delegationId ?? ''} style={styles.delRow}>
                <Text style={styles.delName}>{d?.delegationName ?? ''}</Text>
                <Text style={styles.delCount}>{d?.count ?? 0}</Text>
              </View>
            ))}
          </>
        )}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: SPACING.md },
  backBtn: { padding: SPACING.xs },
  headerTitle: { fontSize: 20, fontWeight: 'bold', color: COLORS.textOnLight },
  content: { padding: SPACING.md, paddingBottom: 60 },
  totalCard: { backgroundColor: COLORS.surface, borderRadius: RADIUS.lg, padding: SPACING.xl, alignItems: 'center', marginBottom: SPACING.lg },
  totalLabel: { color: COLORS.textSecondary, fontSize: 16, marginTop: SPACING.sm },
  totalNumber: { color: COLORS.primary, fontSize: 40, fontWeight: 'bold' },
  sectionTitle: { color: COLORS.textPrimary, fontSize: 18, fontWeight: 'bold', marginBottom: SPACING.md },
  empty: { color: COLORS.textSecondary, fontSize: 14, textAlign: 'center' },
  barRow: { flexDirection: 'row', alignItems: 'center', marginBottom: SPACING.sm, gap: SPACING.sm },
  barLabel: { width: 90, color: COLORS.textSecondary, fontSize: 13 },
  barTrack: { flex: 1, height: 16, backgroundColor: COLORS.surfaceElevated, borderRadius: RADIUS.sm, overflow: 'hidden' },
  barFill: { height: '100%', backgroundColor: COLORS.secondary, borderRadius: RADIUS.sm },
  barCount: { width: 36, color: COLORS.textPrimary, fontSize: 13, textAlign: 'right', fontWeight: '600' },
  delRow: { flexDirection: 'row', justifyContent: 'space-between', backgroundColor: COLORS.surface, padding: SPACING.md, borderRadius: RADIUS.sm, marginBottom: SPACING.sm },
  delName: { color: COLORS.textPrimary, fontSize: 14 },
  delCount: { color: COLORS.secondary, fontSize: 14, fontWeight: 'bold' },
});
