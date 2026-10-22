import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet, ScrollView, Alert, Platform, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS, TRADE_TYPES, TRADE_TYPE_LABELS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useAuth } from '@/src/contexts/AuthContext';
import { merchantsControllerSetup, merchantsControllerUpdateMe, governoratesControllerFindAll, governoratesControllerFindDelegations } from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';
import type { GovernorateItemDto, DelegationItemDto, MerchantSetupDtoTradeType } from '@/src/api/generated/schemas';

export default function MerchantSetupScreen() {
  const { t, locale } = useLocale();
  const { user, refreshUser } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [shopName, setShopName] = useState('');
  const [phone, setPhone] = useState('');
  const [tradeType, setTradeType] = useState<string>('');
  const [governorateId, setGovernorateId] = useState('');
  const [delegationId, setDelegationId] = useState('');
  const [governorates, setGovernorates] = useState<GovernorateItemDto[]>([]);
  const [delegations, setDelegations] = useState<DelegationItemDto[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const isEdit = user?.merchantSetupComplete === true;

  useEffect(() => {
    governoratesControllerFindAll().then(r => setGovernorates(r?.items ?? [])).catch(() => {});
  }, []);

  useEffect(() => {
    if (governorateId) {
      governoratesControllerFindDelegations(governorateId).then(r => setDelegations(r?.items ?? [])).catch(() => {});
    } else {
      setDelegations([]);
      setDelegationId('');
    }
  }, [governorateId]);

  const handleSave = async () => {
    if (!shopName?.trim() || !phone?.trim() || !tradeType || !governorateId || !delegationId) {
      setError(locale === 'ar' ? 'الرجاء ملء جميع الحقول' : 'Veuillez remplir tous les champs');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const payload = {
        shopName: shopName.trim(),
        phone: phone.trim(),
        tradeType: tradeType as 'clothing' | 'food' | 'electronics' | 'furniture' | 'jewelry' | 'household' | 'toys' | 'other',
        governorateId,
        delegationId,
      };
      if (isEdit) {
        await merchantsControllerUpdateMe(payload);
      } else {
        await merchantsControllerSetup(payload);
      }
      await refreshUser();
      router.back();
    } catch (e) {
      setError(getErrorMessage(e, 'Failed'));
    } finally {
      setLoading(false);
    }
  };

  const govName = (g: GovernorateItemDto) => locale === 'ar' ? g?.nameAr : g?.nameFr;
  const delName = (d: DelegationItemDto) => locale === 'ar' ? d?.nameAr : d?.nameFr;

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}> 
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} />
        </Pressable>
        <Text style={styles.headerTitle}>{isEdit ? t('editShop') : t('setupShop')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        {!!error && <Text style={styles.errorText}>{error}</Text>}

        <Text style={styles.label}>{t('shopName')}</Text>
        <TextInput style={styles.input} value={shopName} onChangeText={setShopName} placeholder={t('shopName')} placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('phone')}</Text>
        <TextInput style={styles.input} value={phone} onChangeText={setPhone} placeholder="+216..." placeholderTextColor={COLORS.textSecondary} keyboardType="phone-pad" />

        <Text style={styles.label}>{t('tradeType')}</Text>
        <View style={styles.chipRow}>
          {TRADE_TYPES.map(tt => (
            <Pressable key={tt} style={[styles.chip, tradeType === tt && styles.chipActive]} onPress={() => setTradeType(tt)}>
              <Text style={[styles.chipText, tradeType === tt && styles.chipTextActive]}>
                {TRADE_TYPE_LABELS[tt]?.[locale] ?? tt}
              </Text>
            </Pressable>
          ))}
        </View>

        <Text style={styles.label}>{t('governorate')}</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.pickerRow}>
          {(governorates ?? []).map(g => (
            <Pressable key={g?.id} style={[styles.chip, governorateId === g?.id && styles.chipActive]} onPress={() => { setGovernorateId(g?.id ?? ''); setDelegationId(''); }}>
              <Text style={[styles.chipText, governorateId === g?.id && styles.chipTextActive]}>{govName(g)}</Text>
            </Pressable>
          ))}
        </ScrollView>

        {delegations?.length > 0 && (
          <>
            <Text style={styles.label}>{t('delegation')}</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.pickerRow}>
              {(delegations ?? []).map(d => (
                <Pressable key={d?.id} style={[styles.chip, delegationId === d?.id && styles.chipActive]} onPress={() => setDelegationId(d?.id ?? '')}>
                  <Text style={[styles.chipText, delegationId === d?.id && styles.chipTextActive]}>{delName(d)}</Text>
                </Pressable>
              ))}
            </ScrollView>
          </>
        )}

        <Pressable style={[styles.saveBtn, loading && { opacity: 0.6 }]} onPress={handleSave} disabled={loading}>
          {loading ? <ActivityIndicator color={COLORS.textOnLight} /> : <Text style={styles.saveBtnText}>{t('save')}</Text>}
        </Pressable>
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
  label: { color: COLORS.textPrimary, fontSize: 15, fontWeight: '600', marginTop: SPACING.md, marginBottom: SPACING.xs },
  input: { backgroundColor: COLORS.surface, color: COLORS.textPrimary, borderRadius: RADIUS.md, padding: SPACING.md, fontSize: 16 },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: SPACING.sm },
  pickerRow: { maxHeight: 44 },
  chip: { backgroundColor: COLORS.surface, paddingHorizontal: SPACING.md, paddingVertical: SPACING.sm, borderRadius: RADIUS.full, marginRight: SPACING.xs, marginBottom: SPACING.xs },
  chipActive: { backgroundColor: COLORS.secondary },
  chipText: { color: COLORS.textSecondary, fontSize: 14 },
  chipTextActive: { color: '#fff', fontWeight: 'bold' },
  saveBtn: { backgroundColor: COLORS.action, borderRadius: RADIUS.md, padding: SPACING.md, alignItems: 'center', marginTop: SPACING.xl },
  saveBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  errorText: { color: COLORS.error, fontSize: 14, textAlign: 'center', marginBottom: SPACING.sm },
});
