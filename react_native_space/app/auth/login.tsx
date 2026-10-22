import React, { useState } from 'react';
import { View, Text, TextInput, Pressable, StyleSheet, ScrollView, KeyboardAvoidingView, Platform, Alert } from 'react-native';
import { Link } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { useAuth } from '@/src/contexts/AuthContext';

export default function LoginScreen() {
  const { t, toggleLocale, locale } = useLocale();
  const { login } = useAuth();
  const insets = useSafeAreaInsets();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async () => {
    if (!email || !password) return;
    setLoading(true);
    setError('');
    try {
      await login(email.trim(), password);
    } catch (e: any) {
      setError(e?.message ?? 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
      <ScrollView style={styles.flex} contentContainerStyle={[styles.container, { paddingTop: insets.top }]}>
        <View style={styles.header}>
          <Pressable style={styles.langBtn} onPress={toggleLocale}>
            <Text style={styles.langText}>{locale === 'ar' ? 'FR' : '\u0639'}</Text>
          </Pressable>
          <Text style={styles.logo}>{t('appName')}</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.title}>{t('login')}</Text>

          {error ? <Text style={styles.error}>{error}</Text> : null}

          <TextInput
            style={styles.input}
            placeholder={t('email')}
            placeholderTextColor={COLORS.textSecondary}
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          <TextInput
            style={styles.input}
            placeholder={t('password')}
            placeholderTextColor={COLORS.textSecondary}
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />

          <Pressable style={[styles.btn, loading && styles.btnDisabled]} onPress={handleLogin} disabled={loading}>
            <Text style={styles.btnText}>{loading ? t('loading') : t('login')}</Text>
          </Pressable>

          <Link href="/auth/signup" asChild>
            <Pressable style={styles.linkBtn}>
              <Text style={styles.linkText}>{t('noAccount')} <Text style={styles.linkBold}>{t('signup')}</Text></Text>
            </Pressable>
          </Link>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1, backgroundColor: COLORS.background },
  container: { flexGrow: 1, paddingBottom: SPACING.xxl },
  header: {
    backgroundColor: COLORS.primary, paddingVertical: SPACING.lg,
    alignItems: 'center', paddingHorizontal: SPACING.md,
  },
  langBtn: {
    position: 'absolute', left: SPACING.md, top: SPACING.lg,
    backgroundColor: '#999', paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm,
  },
  langText: { color: COLORS.textOnLight, fontWeight: 'bold', fontSize: 14 },
  logo: { fontSize: 32, fontWeight: 'bold', color: COLORS.textOnLight },
  card: {
    margin: SPACING.lg, backgroundColor: COLORS.surface,
    borderRadius: RADIUS.lg, padding: SPACING.lg, borderWidth: 1, borderColor: COLORS.surfaceElevated,
  },
  title: { fontSize: 24, fontWeight: 'bold', color: COLORS.textPrimary, marginBottom: SPACING.lg, textAlign: 'center' },
  error: { color: COLORS.error, textAlign: 'center', marginBottom: SPACING.md },
  input: {
    backgroundColor: COLORS.surfaceElevated, borderRadius: RADIUS.sm, padding: SPACING.md,
    color: COLORS.textPrimary, fontSize: 16, marginBottom: SPACING.md,
  },
  btn: {
    backgroundColor: COLORS.primary, borderRadius: RADIUS.sm, padding: SPACING.md,
    alignItems: 'center', marginTop: SPACING.sm,
  },
  btnDisabled: { opacity: 0.6 },
  btnText: { color: COLORS.textOnLight, fontWeight: 'bold', fontSize: 16 },
  linkBtn: { marginTop: SPACING.lg, alignItems: 'center' },
  linkText: { color: COLORS.textSecondary, fontSize: 14 },
  linkBold: { color: COLORS.secondary, fontWeight: 'bold' },
});
