import React, { useState } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet, ScrollView, ActivityIndicator, Alert } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { reportsControllerCreate } from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';

const REASONS = ['counterfeit', 'fraud', 'inappropriate', 'other'] as const;

export default function ReportMerchantScreen() {
  const { merchantId = '' } = useLocalSearchParams<{ merchantId: string }>();
  const { t, locale } = useLocale();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [reason, setReason] = useState<string>('');
  const [details, setDetails] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleSend = async () => {
    if (!reason) {
      setError(locale === 'ar' ? 'الرجاء اختيار السبب' : 'Veuillez sélectionner une raison');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await reportsControllerCreate({
        merchantId,
        reason: reason as 'counterfeit' | 'fraud' | 'inappropriate' | 'other',
        details: details?.trim() || undefined,
      });
      setSent(true);
    } catch (e) {
      setError(getErrorMessage(e, 'Failed'));
    } finally { setLoading(false); }
  };

  if (sent) {
    return (
      <View style={[styles.container, { paddingTop: insets.top }]}>
        <View style={styles.header}>
          <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
          <Text style={styles.headerTitle}>{t('report')}</Text>
          <View style={{ width: 40 }} />
        </View>
        <View style={styles.successView}>
          <Ionicons name="checkmark-circle" size={64} color={COLORS.action} />
          <Text style={styles.successText}>{t('reportSent')}</Text>
          <Pressable style={styles.backButton} onPress={() => router.back()}>
            <Text style={styles.backButtonText}>{locale === 'ar' ? 'رجوع' : 'Retour'}</Text>
          </Pressable>
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
        <Text style={styles.headerTitle}>{t('report')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        {!!error && <Text style={styles.errorText}>{error}</Text>}

        <Text style={styles.label}>{t('reportReason')}</Text>
        {REASONS.map(r => (
          <Pressable key={r} style={[styles.reasonBtn, reason === r && styles.reasonActive]} onPress={() => setReason(r)}>
            <Ionicons name={reason === r ? 'radio-button-on' : 'radio-button-off'} size={22} color={reason === r ? COLORS.secondary : COLORS.textSecondary} />
            <Text style={[styles.reasonText, reason === r && { color: COLORS.textPrimary }]}>{t(r)}</Text>
          </Pressable>
        ))}

        <Text style={styles.label}>{t('details')}</Text>
        <TextInput
          style={[styles.input, { minHeight: 100, textAlignVertical: 'top' }]}
          value={details}
          onChangeText={setDetails}
          multiline
          placeholder={locale === 'ar' ? 'أضف تفاصيل إضافية...' : 'Ajoutez des détails supplémentaires...'}
          placeholderTextColor={COLORS.textSecondary}
        />

        <Pressable style={[styles.sendBtn, loading && { opacity: 0.6 }]} onPress={handleSend} disabled={loading}>
          {loading ? <ActivityIndicator color="#fff" /> : (
            <><Ionicons name="send" size={20} color="#fff" /><Text style={styles.sendBtnText}>{t('send')}</Text></>
          )}
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
  label: { color: COLORS.textPrimary, fontSize: 15, fontWeight: '600', marginTop: SPACING.md, marginBottom: SPACING.sm },
  reasonBtn: { flexDirection: 'row', alignItems: 'center', gap: SPACING.md, backgroundColor: COLORS.surface, padding: SPACING.md, borderRadius: RADIUS.md, marginBottom: SPACING.sm },
  reasonActive: { borderWidth: 1, borderColor: COLORS.secondary },
  reasonText: { color: COLORS.textSecondary, fontSize: 16 },
  input: { backgroundColor: COLORS.surface, color: COLORS.textPrimary, borderRadius: RADIUS.md, padding: SPACING.md, fontSize: 16 },
  sendBtn: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: SPACING.sm, backgroundColor: COLORS.error, borderRadius: RADIUS.md, padding: SPACING.md, marginTop: SPACING.xl },
  sendBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  errorText: { color: COLORS.error, fontSize: 14, textAlign: 'center', marginBottom: SPACING.sm },
  successView: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: SPACING.md },
  successText: { color: COLORS.textPrimary, fontSize: 20, fontWeight: 'bold' },
  backButton: { backgroundColor: COLORS.secondary, paddingHorizontal: SPACING.xl, paddingVertical: SPACING.md, borderRadius: RADIUS.md, marginTop: SPACING.md },
  backButtonText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
});
