import { View, Text, StyleSheet, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { COLORS, SPACING } from '@/src/constants/theme';

export default function NotFound() {
  const router = useRouter();
  return (
    <View style={styles.c}>
      <Text style={styles.t}>404</Text>
      <Text style={styles.s}>\u0627\u0644\u0635\u0641\u062d\u0629 \u063a\u064a\u0631 \u0645\u0648\u062c\u0648\u062f\u0629</Text>
      <Pressable style={styles.b} onPress={() => router.replace('/')}>
        <Text style={styles.bt}>\u0627\u0644\u0631\u062c\u0648\u0639</Text>
      </Pressable>
    </View>
  );
}
const styles = StyleSheet.create({
  c: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: COLORS.background },
  t: { fontSize: 48, fontWeight: 'bold', color: COLORS.primary },
  s: { fontSize: 18, color: COLORS.textSecondary, marginTop: SPACING.md },
  b: { marginTop: SPACING.lg, backgroundColor: COLORS.primary, paddingHorizontal: SPACING.lg, paddingVertical: SPACING.md, borderRadius: 12 },
  bt: { color: COLORS.textOnLight, fontWeight: 'bold', fontSize: 16 },
});
