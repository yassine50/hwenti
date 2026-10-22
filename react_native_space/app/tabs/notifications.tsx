import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, Pressable, RefreshControl, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import {
  notificationsControllerFindAll, notificationsControllerMarkRead,
  followsControllerFindAll, followsControllerUnfollow,
} from '@/src/api/generated/api';
import type { NotificationItemDto, FollowItemDto } from '@/src/api/generated/schemas';

export default function NotificationsScreen() {
  const { t } = useLocale();
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const [tab, setTab] = useState<'notifs' | 'follows'>('notifs');
  const [notifs, setNotifs] = useState<NotificationItemDto[]>([]);
  const [follows, setFollows] = useState<FollowItemDto[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadNotifs = useCallback(async () => {
    try {
      const res = await notificationsControllerFindAll({});
      setNotifs(res?.items ?? []);
    } catch {}
  }, []);

  const loadFollows = useCallback(async () => {
    try {
      const res = await followsControllerFindAll({});
      setFollows(res?.items ?? []);
    } catch {}
  }, []);

  useFocusEffect(useCallback(() => {
    loadNotifs();
    loadFollows();
  }, [loadNotifs, loadFollows]));

  const onRefresh = async () => {
    setRefreshing(true);
    await (tab === 'notifs' ? loadNotifs() : loadFollows());
    setRefreshing(false);
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('notifications')}</Text>
      </View>
      <View style={styles.tabBar}>
        <Pressable style={[styles.tabBtn, tab === 'notifs' && styles.tabBtnActive]} onPress={() => setTab('notifs')}>
          <Text style={[styles.tabText, tab === 'notifs' && styles.tabTextActive]}>{t('notifications')}</Text>
        </Pressable>
        <Pressable style={[styles.tabBtn, tab === 'follows' && styles.tabBtnActive]} onPress={() => setTab('follows')}>
          <Text style={[styles.tabText, tab === 'follows' && styles.tabTextActive]}>{t('follows')}</Text>
        </Pressable>
      </View>

      {tab === 'notifs' ? (
        <FlatList
          data={notifs ?? []}
          keyExtractor={item => item?.id ?? ''}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
          renderItem={({ item }) => (
            <Pressable
              style={[styles.notifCard, !item?.isRead && styles.notifUnread]}
              onPress={async () => {
                if (!item?.isRead) await notificationsControllerMarkRead(item?.id ?? '').catch(() => {});
                if (item?.productId) router.push(`/product/${item.productId}`);
              }}
            >
              <Ionicons name="notifications" size={24} color={COLORS.primary} />
              <View style={styles.notifContent}>
                <Text style={styles.notifMsg}>{item?.message ?? ''}</Text>
                <Text style={styles.notifDate}>{item?.createdAt ? new Date(item.createdAt).toLocaleDateString() : ''}</Text>
              </View>
            </Pressable>
          )}
          ListEmptyComponent={
            <View style={styles.empty}>
              <Ionicons name="notifications-off-outline" size={48} color={COLORS.textSecondary} />
              <Text style={styles.emptyText}>{t('noNotifications')}</Text>
            </View>
          }
          contentContainerStyle={styles.list}
        />
      ) : (
        <FlatList
          data={follows ?? []}
          keyExtractor={item => item?.id ?? ''}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={COLORS.primary} />}
          renderItem={({ item }) => (
            <View style={styles.followCard}>
              <Pressable style={styles.followInfo} onPress={() => router.push(`/merchant/${item?.merchant?.id}`)}>
                <Ionicons name="storefront" size={24} color={COLORS.secondary} />
                <View style={styles.followText}>
                  <Text style={styles.followName}>{item?.merchant?.shopName ?? ''}</Text>
                  <Text style={styles.followType}>{item?.merchant?.governorateName ?? ''}</Text>
                </View>
              </Pressable>
              <Pressable
                style={styles.unfollowBtn}
                onPress={async () => {
                  await followsControllerUnfollow(item?.merchant?.id ?? '').catch(() => {});
                  loadFollows();
                }}
              >
                <Text style={styles.unfollowText}>{t('unfollow')}</Text>
              </Pressable>
            </View>
          )}
          ListEmptyComponent={
            <View style={styles.empty}>
              <Ionicons name="people-outline" size={48} color={COLORS.textSecondary} />
              <Text style={styles.emptyText}>{t('noNotifications')}</Text>
            </View>
          }
          contentContainerStyle={styles.list}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: COLORS.background },
  header: { backgroundColor: COLORS.primary, padding: SPACING.md, alignItems: 'center' },
  title: { fontSize: 22, fontWeight: 'bold', color: COLORS.textOnLight },
  tabBar: { flexDirection: 'row', backgroundColor: COLORS.surface },
  tabBtn: { flex: 1, padding: SPACING.md, alignItems: 'center' },
  tabBtnActive: { borderBottomWidth: 2, borderBottomColor: COLORS.primary },
  tabText: { color: COLORS.textSecondary, fontSize: 15, fontWeight: '600' },
  tabTextActive: { color: COLORS.primary },
  list: { paddingTop: SPACING.md, paddingBottom: 20 },
  notifCard: {
    flexDirection: 'row', padding: SPACING.md, marginHorizontal: SPACING.md, marginBottom: SPACING.sm,
    backgroundColor: COLORS.surface, borderRadius: RADIUS.md, gap: SPACING.md,
  },
  notifUnread: { borderLeftWidth: 3, borderLeftColor: COLORS.primary },
  notifContent: { flex: 1 },
  notifMsg: { color: COLORS.textPrimary, fontSize: 14 },
  notifDate: { color: COLORS.textSecondary, fontSize: 12, marginTop: SPACING.xs },
  followCard: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    padding: SPACING.md, marginHorizontal: SPACING.md, marginBottom: SPACING.sm,
    backgroundColor: COLORS.surface, borderRadius: RADIUS.md,
  },
  followInfo: { flexDirection: 'row', alignItems: 'center', gap: SPACING.md, flex: 1 },
  followText: { flex: 1 },
  followName: { color: COLORS.textPrimary, fontSize: 15, fontWeight: '600' },
  followType: { color: COLORS.textSecondary, fontSize: 13 },
  unfollowBtn: { backgroundColor: COLORS.error, paddingHorizontal: SPACING.md, paddingVertical: SPACING.xs, borderRadius: RADIUS.sm },
  unfollowText: { color: '#fff', fontSize: 12, fontWeight: 'bold' },
  empty: { alignItems: 'center', paddingTop: 80 },
  emptyText: { color: COLORS.textSecondary, fontSize: 16, marginTop: SPACING.md },
});
