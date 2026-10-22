import React, { useEffect, useState } from 'react';
import { View, Text, Pressable, TextInput, StyleSheet, ScrollView, Image, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { COLORS, SPACING, RADIUS } from '@/src/constants/theme';
import { useLocale } from '@/src/contexts/LocaleContext';
import { productsControllerFindOne, productsControllerUpdate, uploadControllerPresigned, uploadControllerComplete } from '@/src/api/generated/api';
import { getErrorMessage } from '@/src/api/customFetch';

export default function EditProductScreen() {
  const { productId = '' } = useLocalSearchParams<{ productId: string }>();
  const { t, locale } = useLocale();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [name, setName] = useState('');
  const [price, setPrice] = useState('');
  const [phone, setPhone] = useState('');
  const [description, setDescription] = useState('');
  const [existingImageIds, setExistingImageIds] = useState<string[]>([]);
  const [existingImageUrls, setExistingImageUrls] = useState<string[]>([]);
  const [newImages, setNewImages] = useState<{ uri: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!productId) return;
    (async () => {
      try {
        const p = await productsControllerFindOne(productId);
        setName(p?.name ?? '');
        setPrice(String(p?.price ?? ''));
        setPhone(p?.phone ?? '');
        setDescription(p?.description ?? '');
        const imgs = p?.images ?? [];
        setExistingImageIds(imgs.map(i => i?.fileId ?? '').filter(Boolean));
        setExistingImageUrls(imgs.map(i => i?.url ?? '').filter(Boolean));
      } catch {} finally { setFetching(false); }
    })();
  }, [productId]);

  const pickImages = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], allowsMultipleSelection: true, quality: 0.7 });
    if (!result.canceled && result.assets?.length) {
      setNewImages(prev => [...prev, ...result.assets.map(a => ({ uri: a.uri }))]);
    }
  };

  const uploadImage = async (uri: string): Promise<string> => {
    const fileName = uri.split('/').pop() ?? `img_${Date.now()}.jpg`;
    const contentType = 'image/jpeg';
    const presigned = await uploadControllerPresigned({ fileName, contentType, isPublic: true });
    const fileResp = await fetch(uri);
    const blob = await fileResp.blob();
    await fetch(presigned?.uploadUrl ?? '', { method: 'PUT', body: blob, headers: { 'Content-Type': contentType } });
    const completed = await uploadControllerComplete({ cloud_storage_path: presigned?.cloud_storage_path ?? '', fileName, contentType });
    return completed?.id ?? '';
  };

  const handleSave = async () => {
    if (!name?.trim() || !price?.trim() || !phone?.trim()) {
      setError(locale === 'ar' ? 'الرجاء ملء الحقول المطلوبة' : 'Veuillez remplir les champs requis');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const uploadedIds: string[] = [];
      for (const img of newImages) {
        const fid = await uploadImage(img?.uri ?? '');
        if (fid) uploadedIds.push(fid);
      }
      await productsControllerUpdate(productId, {
        name: name.trim(),
        price: parseFloat(price) || 0,
        phone: phone.trim(),
        description: description?.trim() || undefined,
        imageFileIds: [...existingImageIds, ...uploadedIds],
      });
      router.back();
    } catch (e) {
      setError(getErrorMessage(e, 'Failed'));
    } finally { setLoading(false); }
  };

  if (fetching) return <View style={[styles.container, { paddingTop: insets.top, justifyContent: 'center', alignItems: 'center' }]}><ActivityIndicator size="large" color={COLORS.primary} /></View>;

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backBtn}><Ionicons name="arrow-back" size={24} color={COLORS.textOnLight} /></Pressable>
        <Text style={styles.headerTitle}>{t('edit')}</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
        {!!error && <Text style={styles.errorText}>{error}</Text>}

        <Text style={styles.label}>{t('productName')} *</Text>
        <TextInput style={styles.input} value={name} onChangeText={setName} placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('price')} (TND) *</Text>
        <TextInput style={styles.input} value={price} onChangeText={setPrice} keyboardType="decimal-pad" placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('phone')} *</Text>
        <TextInput style={styles.input} value={phone} onChangeText={setPhone} keyboardType="phone-pad" placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('description')}</Text>
        <TextInput style={[styles.input, { minHeight: 80, textAlignVertical: 'top' }]} value={description} onChangeText={setDescription} multiline placeholderTextColor={COLORS.textSecondary} />

        <Text style={styles.label}>{t('selectImages')}</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.imageRow}>
          <Pressable style={styles.addImageBtn} onPress={pickImages}>
            <Ionicons name="camera-outline" size={32} color={COLORS.textSecondary} />
          </Pressable>
          {existingImageUrls.map((url, idx) => (
            <View key={`ex-${idx}`} style={styles.imgWrapper}>
              <Image source={{ uri: url }} style={styles.imgThumb} />
              <Pressable style={styles.removeImg} onPress={() => {
                setExistingImageIds(prev => prev.filter((_, i) => i !== idx));
                setExistingImageUrls(prev => prev.filter((_, i) => i !== idx));
              }}>
                <Ionicons name="close-circle" size={22} color={COLORS.error} />
              </Pressable>
            </View>
          ))}
          {newImages.map((img, idx) => (
            <View key={`new-${idx}`} style={styles.imgWrapper}>
              <Image source={{ uri: img?.uri }} style={styles.imgThumb} />
              <Pressable style={styles.removeImg} onPress={() => setNewImages(prev => prev.filter((_, i) => i !== idx))}>
                <Ionicons name="close-circle" size={22} color={COLORS.error} />
              </Pressable>
            </View>
          ))}
        </ScrollView>

        <Pressable style={[styles.saveBtn, loading && { opacity: 0.6 }]} onPress={handleSave} disabled={loading}>
          {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles.saveBtnText}>{t('save')}</Text>}
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
  imageRow: { marginTop: SPACING.sm },
  addImageBtn: { width: 80, height: 80, backgroundColor: COLORS.surface, borderRadius: RADIUS.md, justifyContent: 'center', alignItems: 'center', marginRight: SPACING.sm, borderWidth: 1, borderColor: COLORS.textSecondary, borderStyle: 'dashed' },
  imgWrapper: { position: 'relative', marginRight: SPACING.sm },
  imgThumb: { width: 80, height: 80, borderRadius: RADIUS.md },
  removeImg: { position: 'absolute', top: -6, right: -6 },
  saveBtn: { backgroundColor: COLORS.action, borderRadius: RADIUS.md, padding: SPACING.md, alignItems: 'center', marginTop: SPACING.xl },
  saveBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
  errorText: { color: COLORS.error, fontSize: 14, textAlign: 'center', marginBottom: SPACING.sm },
});
